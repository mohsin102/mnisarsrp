public class EnergyLinkPostResponseWrapper {
	
    public List<Results> results;  
    
    public class Results {
		public String url;
		public List<String> auth;
		public String receivedOn;
	}
    public static EnergyLinkPostResponseWrapper parse(String json) {
		return (EnergyLinkPostResponseWrapper) System.JSON.deserialize(json, EnergyLinkPostResponseWrapper.class);
	}
}