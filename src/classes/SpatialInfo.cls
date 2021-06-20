global class SpatialInfo {

    public class Geometry {
        public List<List<List<Double>>> rings;
    }

    public String displayFieldName;
    public List<Features> features;

    public class Attributes {
        public String Tract_Name;
    }

    public class Features {
        public Attributes attributes;
        public Geometry geometry;
    }

    public SpatialInfo parse(String json) {
        return (SpatialInfo) System.JSON.deserialize(json, SpatialInfo.class);
    }
}