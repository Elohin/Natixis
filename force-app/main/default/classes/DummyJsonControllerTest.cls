/**
 * 1. Calling API via Mock
 * 2. Upsert data
 * 3. Empty Filter 
 * 4. Limit 100 products/category
 * 5. Limit 10k value/category
 * 6. Filtering results
 */
@isTest
private class DummyJsonControllerTest {

    @isTest
    static void myUnitTest() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Map<String,String> filter = new Map<String,String>();
        List<Product2> productsCallout = DummyJsonController.makeCallout(filter);

        List<Product2> productsInserted = [SELECT External_Id__c, Name, Description, Price__c, Discount__c, Rating__c, Stock__c, Brand__c, Category__c, DisplayUrl, Id FROM Product2];
        
        // Upsert Validation
        System.assertEquals(4, productsInserted.size());

        // Empty Filter
        System.assertEquals(3, productsCallout.size());

        // Limit 100 products/category
        Map<String,Integer> productsMap = new Map<String,Integer>();
        for(Product2 product: productsCallout){
            Integer products = productsMap.containsKey(product.Category__c) ? productsMap.get(product.Category__c) : 0;
            products += (Integer) product.Stock__c;
            productsMap.put(product.Category__c,products);
        }

        for(Integer products: productsMap.values()){
            System.assert(products<=100);
        }

        // Limit 10k value/category
        Map<String,Decimal> sumProductsMap = new Map<String,Decimal>();
        for(Product2 product: productsCallout){
            Decimal products = sumProductsMap.containsKey(product.Category__c) ? sumProductsMap.get(product.Category__c) : 0;
            products += product.Stock__c * product.Price__c;
            sumProductsMap.put(product.Category__c,products);
        }

        for(Decimal sumProducts: sumProductsMap.values()){
            System.assert(sumProducts<=10000);
        }



    }

    @isTest
    static void filterTest() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Filtering results
        Map<String,String> filter = new Map<String,String>();
        filter.put('filterCategory','Name');
        filter.put('filterInput','iphone x');
        List<Product2> filteredProductsCallout = DummyJsonController.makeCallout(filter);
        System.assertEquals(1, filteredProductsCallout.size());
    }
}