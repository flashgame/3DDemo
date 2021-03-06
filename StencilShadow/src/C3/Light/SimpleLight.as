package C3.Light
{
	import flash.geom.Vector3D;

	public class SimpleLight
	{
		public var pos : Vector3D = new Vector3D();
		
		private var m_ambient : Vector.<Number>
		private var m_color : Vector.<Number>;
		private var m_lightFov : Number = 0;
		
		public function SimpleLight(color : uint, alpha : Number) : void
		{
			var r : Number = ((color & 0xFF0000) >> 16)/256;
			var g : Number = ((color & 0x00FF00) >> 8)/256;
			var b : Number = (color & 0x0000FF)/256;
			m_color = Vector.<Number>([r,g,b,alpha]);
		}
		
		public function set fov(value : Number) : void
		{
			m_lightFov = value;
		}
		
		public function get fov() : Number
		{
			return m_lightFov;
		}
		
		public function setAmbient(r : Number, g : Number, b : Number, a : Number) : void
		{
			m_ambient = Vector.<Number>([r,g,b,a]);
		}
		
		public function getAmbient() : Vector.<Number>
		{
			if(null == m_ambient) 
				m_ambient = Vector.<Number>([1,1,1,0]);
			
			return m_ambient;
		}
		
		public function getNegAmbient() : Vector.<Number>
		{
			if(null == m_ambient) 
				m_ambient = Vector.<Number>([1,1,1,0]);
			
			return new Vector.<Number>([1 - m_ambient[0], 1- m_ambient[1], 1 - m_ambient[2], 1 - m_ambient[3]]);
		}
		
		public function setColor(r : Number, g : Number, b: Number, a : Number) : void
		{
			m_color = Vector.<Number>([r,g,b,a]);
		}
		
		public function getColor() : Vector.<Number>
		{
			return m_color;
		}
		
		public function get normalize() : Vector3D
		{
			var n : Vector3D = pos.clone();
			n.normalize();
			n.negate();
			return n;
		}
		
		public function get x() : Number
		{
			return pos.x;
		}
		
		public function get y() : Number
		{
			return pos.y;
		}
		
		public function get z() : Number
		{
			return pos.z;
		}
	}
}