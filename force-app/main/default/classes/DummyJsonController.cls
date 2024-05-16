public class DummyJsonController {  

    @AuraEnabled()
    public static List<Product2> makeCallout(Map<String,String> filter){

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DummyJsonCallout/product?limit=0');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
		List<Product2> productList = new List<Product2>();
        
        if(res.getStatusCode() == 200){

            Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> productObjList = (List<Object>) returnMap.get('products');
            for(Object productObj: productObjList){
                Map<String,Object> productMap = (Map<String,Object>) productObj;
                Product2 product = New Product2();
                product.External_Id__c = (Integer) productMap.get('id');
                product.Name = (String) productMap.get('title');
                product.Description = (String) productMap.get('description');
                product.Price__c = (Decimal) productMap.get('price');
                product.Discount__c = (Decimal) productMap.get('discountPercentage');
                product.Rating__c = (Decimal) productMap.get('rating');
                product.Stock__c = (Integer) productMap.get('stock');
                product.Brand__c = (String) productMap.get('brand');
                product.Category__c = (String) productMap.get('category');
                product.DisplayUrl = (String) productMap.get('thumbnail');
                productList.add(product);               
            }
            try{
				upsert productList External_Id__c;                       
            } catch (DmlException e){
                System.debug(e.getMessage());
            }
       	}

        String lastCategory = '';
        Decimal totalSum = 0.0;
        Integer products = 0;
        Decimal sumProducts = 0.0;
        List<Product2> filteredList = new List<Product2>();
        List<Product2> retList = new List<Product2>();

        for(Product2 product: productList){
            if(product.Category__c != lastCategory){
                lastCategory = product.Category__c;
                products = 0;
                sumProducts = 0.0;
            }

            Boolean filterOK = false;

            String recValue = '';
            
            if(filter.get('filterCategory') != null){
                recValue = (String)(product.get(filter.get('filterCategory')));
            }

            filterOK = (String.isEmpty(filter.get('filterCategory')) || String.isEmpty(filter.get('filterInput'))) 
            || (recValue.containsIgnoreCase(filter.get('filterInput')));

            if(products < 100 && sumProducts < 10000 && filterOK){
                if(products + product.Stock__c > 100){
                    product.Stock__c = 100 - products;
                }
                products += (Integer) product.Stock__c;
                
                if(sumProducts + product.Stock__c * product.Price__c > 10000){
                    products -= (Integer) Math.ceil(product.Stock__c - (10000 - sumProducts) / product.Price__c);

                    product.Stock__c = Math.floor((10000 - sumProducts) / product.Price__c);
                }
                sumProducts += product.Stock__c * product.Price__c;
            
                totalSum += product.Stock__c * product.Price__c;
                if(product.Stock__c > 0){
                    retList.add(product);
                }
            }
        }

        return retList;
    }
}