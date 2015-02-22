
class ProductService

    @headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
    @defaultConfig = { headers: @headers }

    constructor: (@$log, @$http, @$q) ->
        @$log.debug "constructing ProductService"

    listProducts: () ->
        @$log.debug "listProducts()"
        deferred = @$q.defer()

        @$http.get("/products")
        .success((data, status, headers) =>
                @$log.info("Successfully listed Products - status #{status}")
                deferred.resolve(data)
            )
        .error((data, status, headers) =>
                @$log.error("Failed to list Products - status #{status}")
                deferred.reject(data)
            )
        deferred.promise

    createProduct: (product) ->
        @$log.debug "createProduct #{angular.toJson(product, true)}"
        deferred = @$q.defer()

        @$http.post('/product', product)
        .success((data, status, headers) =>
                @$log.info("Successfully created Product - status #{status}")
                deferred.resolve(data)
            )
        .error((data, status, headers) =>
                @$log.error("Failed to create product - status #{status}")
                deferred.reject(data)
            )
        deferred.promise

    updateProduct: (productId, product) ->
      @$log.debug "updateProduct #{angular.toJson(product, true)}"
      deferred = @$q.defer()

      @$http.put("/product/#{productId}", product)
      .success((data, status, headers) =>
              @$log.info("Successfully updated Product - status #{status}")
              deferred.resolve(data)
            )
      .error((data, status, header) =>
              @$log.error("Failed to update product - status #{status}")
              deferred.reject(data)
            )
      deferred.promise

    removeProduct: (product) ->
      @$log.debug "removeProduct #{angular.toJson(product, true)}"
      deferred = @$q.defer()

      @$http.post("/removeProduct", product)
      .success((data, status, headers) =>
              @$log.info("Successfully removed Product - status #{status}")
              deferred.resolve(data)
            )
      .error((data, status, header) =>
              @$log.error("Failed to remove product - status #{status}")
              deferred.reject(data)
            )
      deferred.promise

servicesModule.service('ProductService', ProductService)