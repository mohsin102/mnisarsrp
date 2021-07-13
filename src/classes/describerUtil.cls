public class describerUtil{
	public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	public List<Pair> lstfieldname{get;set;}
	public List <Pair> fields {get{return lstfieldname;} set{lstfieldname =value;}}
	public List <SelectOption> objectNames{public get; private set;}
	public String selectedObject {get; set;}

	// Intialize objectNames and fields

	public describerUtil() {
		objectNames = initObjNames();
		fields = new List<Pair>();
	}
	// Populate SelectOption list -

	// find all sObjects available in the organization

	private List<SelectOption> initObjNames() {
		List<SelectOption> objNames = new List<SelectOption>();
		List<String> entities = new List<String>(schemaMap.keySet());
		entities.sort();
		for(String name : entities)
		objNames.add(new SelectOption(name,name));
		return objNames;
	}

	//Methods not currently being used, but may be useful in the future.  Commenting out unused code.
	// Find the fields for the selected object
	/*
	public void showFields() {
		//fields.clear();
		system.debug('$$$$$' + selectedObject);
		Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedObject).getDescribe().fields.getMap();
		for(Schema.SObjectField sfield : fieldMap.Values()){
			schema.describefieldresult dfield = sfield.getDescribe();
			system.debug('#######' + dfield );
			Pair field = new Pair();
			field.key = dfield.getname();
			system.debug('#######4444' + field.key);
			field.val = dfield.getType () + ' : ' + dfield.getLabel ();
			lstfieldname.add(field);
		}
	}*/

	/*
	public List<String> getFieldNames(){
		List<String> sObjectNames = new List<String>();
		sObjectNames.add(selectedObject);
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(sObjectNames);
		List<String> fieldNames = new List<String>();
		for(Schema.DescribeSobjectResult res : results) {
			fieldNames.addAll(res.fields.getMap().keyset());
			System.debug(res.fields.getMap().keyset());
			//System.debug(res.fields);
			//System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
			
			// Get child relationships
			Schema.ChildRelationship[] rels = res.getChildRelationships();
			if (rels.size() > 0) {
				System.debug(res.getName() + ' has ' + rels.size() + ' child relationships.');
			}
		}
		return fieldNames;
	}*/

	public Map<String, Schema.SObjectField> getFields(){
		List<String> sObjectNames = new List<String>();
		sObjectNames.add(selectedObject);
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(sObjectNames);
		Map<String, Schema.SObjectField> fieldNames = new Map<String, Schema.SObjectField>();
		for(Schema.DescribeSobjectResult res : results) {
			fieldNames = res.fields.getMap();
		}
		return fieldNames;
	}


	public class Pair{
		public String key {get; set;}
		public String val {get; set;}
	
	}
}