package
{
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import C3.MD5.MD5Result;

	public class MD5Test extends ContextBase
	{
		public function MD5Test()
		{
			super();
		}
		
		private function onComplete(e:Event) : void
		{
			m_hasMeshData = true;
		}
		
		protected override function onCreateContext(e:Event):void
		{
			super.onCreateContext(e);
			
			md5Result = new MD5Result(m_context);
			md5Result.addEventListener("meshLoaded", onComplete);
			md5Result.loadModel(new mesh as ByteArray);
			
			m_texture = Utils.getTexture(textureData,m_context);
			
			m_headTexture = Utils.getTexture(headTextureData, m_context);
			m_equipTexture = Utils.getTexture(equipTextureData, m_context);
			m_weaponTexture = Utils.getTexture(weaponTextureData, m_context);
			m_faceTexture = Utils.getTexture(faceTextureData, m_context);
			
			m_textureList = new <Texture>[m_headTexture,m_equipTexture,m_weaponTexture,m_faceTexture];
			
			stage.addEventListener(Event.ENTER_FRAME, onEnter);
		}
		
		private var t : Number = 0;
		private function onEnter(e:Event) : void
		{
			m_context.clear(0,0,0,0);
			
			t += 1;
			
			if(!m_hasMeshData) return;
			
			m_context.setProgram(md5Result.program);
						
			m_modelMatrix.identity();
			m_modelMatrix.appendRotation(-90,Vector3D.X_AXIS);
			m_modelMatrix.appendRotation(t, Vector3D.Y_AXIS);
			m_modelMatrix.appendScale(.5,.5,.5);
			m_modelMatrix.appendTranslation(0,-30,-50);
			
			m_finalMatrix.identity();
			m_finalMatrix.append(m_modelMatrix);
			m_finalMatrix.append(m_viewMatrix);
			m_finalMatrix.append(m_projMatrix);
			
			m_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 124, m_finalMatrix, true);
			
//			m_context.setTextureAt(0, m_texture);
			for(var i : int = 0; i < md5Result.meshDataNum; i++){
				var vertexBuffer : VertexBuffer3D = md5Result.vertexBufferList[i];
				var uvBuffer : VertexBuffer3D = md5Result.uvBufferList[i];
				var indexBuffer : IndexBuffer3D = md5Result.indexBufferList[i];
				var texture : Texture = m_textureList[i];
				
				m_context.setTextureAt(0, texture);
				m_context.setVertexBufferAt(0, vertexBuffer,0, Context3DVertexBufferFormat.FLOAT_3);
				m_context.setVertexBufferAt(1,uvBuffer,0,Context3DVertexBufferFormat.FLOAT_2);
				m_context.drawTriangles(indexBuffer);
				m_context.setTextureAt(0, null);
			}
			m_context.present();
		}
		
		[Embed(source="../source/meizi/meizi.md5mesh", mimeType="application/octet-stream")]
		private var mesh : Class;
	
		[Embed(source="../source/hellknight/hellknight_diffuse.jpg")]
		private var textureData : Class;
		
		[Embed(source="../source/meizi/chujitou.jpg")]
		private var headTextureData : Class;
		
		[Embed(source="../source/meizi/chujizhuang3.jpg")]
		private var equipTextureData : Class;
		
		[Embed(source="../source/meizi/dao.jpg")]
		private var weaponTextureData : Class;
		
		[Embed(source="../source/meizi/nvlian1.jpg")]
		private var faceTextureData : Class;
		
		private var md5Result : MD5Result;
		private var m_hasMeshData : Boolean;
		private var m_texture : Texture;
		private var m_modelMatrix : Matrix3D = new Matrix3D();
		
		private var m_headTexture : Texture;
		private var m_equipTexture : Texture;
		private var m_weaponTexture : Texture;
		private var m_faceTexture : Texture;
		private var m_textureList : Vector.<Texture>;
	}
}