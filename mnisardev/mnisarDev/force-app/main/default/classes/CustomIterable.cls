global class CustomIterable implements Iterator <String> {

    List<String> sObjectList {get; set;}
    Integer i {get;set;}

    global CustomIterable(List<String> sObjectList) {
        this.sObjectList = sObjectList;
        i = 0;
    }
    // This is Iterator interface hasNext() method, it will
    // return true if the list 'con' contains records else it
    // will return false;

    global boolean hasNext() {
        if (i >= sObjectList.size()) {
            return false;
        } else {
            return true;
        }
    }

    global String next(){
        if(i==sObjectList.size()){
            return null;
        }else{
            i++;
            return sObjectList[i-1];
        }
    }
}