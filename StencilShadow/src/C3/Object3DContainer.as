package C3
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	
	import C3.Camera.Camera;
	import C3.Material.IMaterial;
	import C3.PostRender.IPostRender;
	
	public class Object3DContainer extends Object3D
	{
		public function Object3DContainer(name:String="", mat:IMaterial = null)
		{
			super(name, mat);
			m_transform = new Matrix3D();
			m_modelList = new Vector.<Object3D>();
		}
		
		public function set isRoot(bool : Boolean) : void
		{
			m_isRoot = bool;
		}
		
		public function get isRoot() : Boolean
		{
			return m_isRoot;
		}
		
		public function set view(value : View) : void
		{
			m_view = value;
		}
		
		public function addChild(target : Object3D) : void
		{
			if(target.parent) 
				target.parent.removeChild(target);
			
			if(m_modelList.indexOf(target) == -1){
				m_modelList.push(target);
				target.parent = this;
				target.visible = true;
//				target.pickEnabled = m_pickEnabled;
//				target.interactive = m_interactive;
//				target.buttonMode = m_buttonMode;
			}
		}
		
		public function removeChild(target : Object3D, needDispose : Boolean = false) : void
		{
			var index : int = m_modelList.indexOf(target);
			if(index != -1){
				m_modelList.splice(index, 1);
				target.parent = null;
				target.visible = false;
			}
			
			if(needDispose) target.dispose();
		}
		
		public function getChildByName(name : String) : Object3D
		{
			var model : Object3D;
			for each(model in m_modelList)
			{
				if(model.name == name) return model;
			}
			
			return null;
		}
		
		public function removeChildren(needDispose : Boolean = false) : void
		{
			var model : Object3D;
			while(m_modelList.length)
			{
				model = m_modelList.shift();
				model.parent = null;
				if(needDispose) model.dispose();
			}
		}
		
		public override function get parent():Object3DContainer
		{
			return m_parent;
		}
		
		public override function set parent(value:Object3DContainer):void
		{
			m_parent = value;
		}
		
		public override function get transform():Matrix3D
		{
			if(m_transformDirty)
				updateTransform();
			
			return m_transform;
		}
		
		/**
		 * 这里要特殊处理，把相机放在proj之前
		 */
		public function appendChildMatrix(matrix : Matrix3D) : void
		{
			matrix.append(transform);
		}
		
		public override function render(context : Context3D, camera : Camera) : void
		{
			m_context = context;
			m_camera = camera;
			
			var model : Object3D;
			for each(model in m_modelList)
			{
				model.render(m_context,m_camera);
			}
		}
		
		public override function dispose():void
		{
			super.dispose();
			m_modelList = null;
			m_transform = null;
		}
		
		public function get children() : Vector.<Object3D>
		{
			return m_modelList;
		}
		
		private var m_view : View;
		private var m_isRoot : Boolean;
		protected var m_modelList : Vector.<Object3D>;
	}
}