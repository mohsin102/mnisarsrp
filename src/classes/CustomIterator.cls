global class CustomIterator implements iterable<String>{
   	global List<String> sObjectList = new List<String>();
    global CustomIterator (List<String> sObjectList){
        this.sObjectList = sObjectList;
    }
    
    global Iterator<String> Iterator(){
      return new CustomIterable(sObjectList);
   }
}