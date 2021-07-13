export {flattenData,sortArray, recordUrl, pageData};

const recordUrl = (recordId) => {
    // converts an Id into a record Url
    let navUrl = {
        type: 'standard__recordPage',
        attributes: {
            'recordId': recordId,
            'actionName': 'view'
        }
    };
    return navUrl;
}

const pageData = (data,page,size) => {
    let newObj = [];
    if (data.length > 0) {
        // Adjust page for proper splice
        let start = parseInt(page-1) * parseInt(size);
        let end = start + parseInt(size);
        let numPages = parseInt(data.length/size);
        if ((data.length % size) > 0) {
            numPages ++;
        }
        //console.log('numpages: ' + numPages);
        end = data.length < end ? data.length : end;

        // now get just the current page
        let dataPaged = [...data].splice(start,size);
        //console.log('len:' + dataPaged.length);
        dataPaged.forEach(row => {
            newObj.push(row);
        });
        if (numPages > 1) {
            newObj.currentPage = page;
            newObj.totalPages = numPages;
        }
    } else {
        return data;
    }
    return newObj;
}


const flattenData = (data) => {
    // takes a SF data object, and adds dot notation to objects more than one level deep
    //console.log('FLAT ROW:'+JSON.stringify(data));
    var newObj = [];
    data.forEach(row => {
        newObj.push(flatten(row));
    })
    return newObj;
}

const sortArray = (arr,key,order) => {
    //console.log('sorting this array ' + JSON.stringify(arr));
    arr.sort(compareValues(key,order));
}

const flatten = (obj) => {
    var newObj = {};
    for (var key in obj) {
        if (typeof obj[key] === 'object' && obj[key] !== null) {
            var temp = flatten(obj[key])
            for (var key2 in temp) {
                newObj[key+"."+key2] = temp[key2];
            }
        } else {
            newObj[key] = obj[key];
        }
    }
    return newObj;
}

// function for dynamic sorting
const compareValues = (key, order='asc') => {
	return function(a, b) {
		//console.log('a value is: ' + JSON.stringify(a) + ' b value is: ' + JSON.stringify(b));
		//console.log('a hasOwnProperty evaluates to: ' + a.hasOwnProperty(key));
		//console.log('b hasOwnProperty evaluates to: ' + b.hasOwnProperty(key));
		if(!a.hasOwnProperty(key) && !b.hasOwnProperty(key)) {
			// property doesn't exist on either object
			return 0;
		}
		var varA;
		var varB;
		if(a.hasOwnProperty(key)){
			varA = (typeof a[key] === 'string') ?
				a[key].toUpperCase() : a[key];
		}
		else{
			varA = '';
		}
		if(b.hasOwnProperty(key)){
			varB = (typeof b[key] === 'string') ?
				b[key].toUpperCase() : b[key];
		}
		else{
			varB = '';
		}
			
		let comparison = 0;
		//console.log('varA value is: ' + varA + ' varB value is: ' + varB);
		if (varA > varB) {
			comparison = 1;
		} else if (varA < varB) {
			comparison = -1;
		}
		return (
			(order == 'desc') ? (comparison * -1) : comparison
		);
	};
}