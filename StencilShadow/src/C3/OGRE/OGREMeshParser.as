package C3.OGRE
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import C3.Event.AOI3DLOADEREVENT;

	public class OGREMeshParser extends EventDispatcher
	{
		public function OGREMeshParser()
		{
		}
		
		public function load(data : ByteArray) : void
		{
			_textData = new XML(data.readUTFBytes(data.bytesAvailable));
			handleData();
		}
		
		private function handleData() : void
		{
			if(_textData.hasOwnProperty(SHARED_GEOMETRY))parseGeometry();
			else parseMeshes();
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function parseGeometry() : void
		{
			var mesh : MeshData = new MeshData();
			var node : XML;
			for each(node in _textData.children())
			{
				var nodeName : String = node.name();
				switch(nodeName){
					case SHARED_GEOMETRY:
						parseVertex(node, mesh);
						break;
					case SUB_MESHS:
						parseIndex(node.child(SUB_MESH).children()[0], mesh);
						break;
				}
			}
			ogre_mesh.push(mesh);
			this.dispatchEvent(new AOI3DLOADEREVENT(AOI3DLOADEREVENT.ON_MESH_LOADED, mesh));
		}
		
		private function parseMeshes() : void
		{
			var node : XML;
			for each(node in _textData.children())
			{
				var nodeName : String = node.name();
				switch(nodeName){
					case SUB_MESHS:
						parseSubMesh(node);
						break;
				}
			}
		}
		
		private function parseSubMesh(data : XML) : void
		{
			var subMeshData : XML = data.child(SUB_MESH)[0];
			var node : XML;
			var mesh : MeshData = new MeshData();;
			for each(node in subMeshData.children())
			{
				var nodeName : String = node.name();
				switch(nodeName){
					case FACE:
						parseIndex(node, mesh);
						break;
					case GEOMETRY:
						parseVertex(node, mesh);
						break;
					case BONE_ASSIGNMENTS:
						parseBone(node, mesh);
						break;
				}
			}
			ogre_mesh.push(mesh);
			this.dispatchEvent(new AOI3DLOADEREVENT(AOI3DLOADEREVENT.ON_MESH_LOADED, mesh));
		}
		
		/**
		 * 解析骨骼
		 */
		private function parseBone(node : XML, mesh : MeshData) : void
		{
			var bone : XML;
			var vertex : OGREVertex;
			var vertexIndex : uint;
			for each(bone in node.children())
			{
				vertexIndex = bone.@vertexindex;
				vertex = mesh.ogre_vertex[vertexIndex];
				vertex.weight_count = bone.@weight;
				vertex.weight_index = bone.@boneindex;
			}
		}
		
		/**
		 * 解析索引
		 */
		private function parseIndex(data : XML, mesh : MeshData) : void
		{
			var numTriangle : uint = data.@count; 
			var face : XML;
			var triangle : OGRETriangle;
			for each(face in data.children())
			{
				triangle = new OGRETriangle();
				triangle.indexVec.push(face.@v1);
				triangle.indexVec.push(face.@v2);
				triangle.indexVec.push(face.@v3);
				mesh.ogre_triangle.push(triangle);
			}
			mesh.ogre_numTriangle = numTriangle;
		}
		
		/**
		 * 解析顶点
		 */
		private function parseVertex(data : XML, mesh : MeshData) : void
		{
			mesh.ogre_numVertex = data.@vertexcount;
			var vertexBuffer : XML;
			var curVertexPositionAndNormalIndex : uint = 0;
			var curVertexUV : uint = 0;
			var vertex : OGREVertex;
			var vertexData : XML;
			var nodeName : String;
			var totalData : XMLList;
			for each(vertexBuffer in data.child(VERTEX_BUFFER).children())
			{
				if(curVertexPositionAndNormalIndex++ < mesh.ogre_numVertex){//解析坐标和法线
					vertex = new OGREVertex();
					for each(vertexData in vertexBuffer.children()){
						nodeName = vertexData.name();
						switch(nodeName){
							case VERTEX_POSITION:
								vertex.pos = new Vector3D(vertexData.@x,vertexData.@y,vertexData.@z);
								break;
							case VERTEX_NORMAL:
								vertex.tangent = new Vector3D(vertexData.@x,vertexData.@y,vertexData.@z);
								break;
						}
					}
					mesh.ogre_vertex.push(vertex);
				}else{//解析UV
					vertex = mesh.ogre_vertex[curVertexUV++];
					for each(vertexData in vertexBuffer.children()){
						nodeName = vertexData.name();
						switch(nodeName){
							case VERTEX_TEXCOORD:
								vertex.uv_x = vertexData.@u;
								vertex.uv_y = vertexData.@v;
								break;
						}
					}
				}
			}
		}
		
		private var _textData : XML;
		private var ogre_mesh : Vector.<MeshData> = new Vector.<MeshData>();
		
		/**独立多边形**/
		private static const SHARED_GEOMETRY : String = "sharedgeometry";
		/**子网格集合**/
		private static const SUB_MESHS : String = "submeshes";
		/**子网格**/
		private static const SUB_MESH : String = "submesh";
		/**面**/
		private static const FACE : String = "faces";
		/**集合体**/
		private static const GEOMETRY : String = "geometry";
		/**顶点缓冲信息**/
		private static const VERTEX_BUFFER : String = "vertexbuffer";
		/**顶点**/
		private static const VERTEX : String = "vertex";
		/**顶点坐标**/
		private static const VERTEX_POSITION : String = "position";
		/**顶点法线**/
		private static const VERTEX_NORMAL : String = "normal";
		/**顶点UV**/
		private static const VERTEX_TEXCOORD : String = "texcoord";
		/**骨骼**/
		private static const BONE_ASSIGNMENTS : String = "boneassignments";
		
	}
}