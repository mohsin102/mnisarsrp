//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class MapResponseError {

	public class Details {
	}

	public Error error;

	public class Error {
		public Integer code;
		public String message;
		public List<Details> details;
	}

	
	public static MapResponseError parse(String json) {
		return (MapResponseError) System.JSON.deserialize(json, MapResponseError.class);
	}
}