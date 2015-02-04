class UpdateProductCtrl

  constructor: (@$log, @$location, @$routeParams, @ProductService) ->
      @$log.debug "constructing UpdateProductController"
      @product = {}
      @findProduct()

  updateProduct: () ->
      @$log.debug "updateProduct()"
      @product.active = true
      @ProductService.updateProduct(@$routeParams.productId, @product)
      .then(
          (data) =>
            @$log.debug "Promise returned #{data} Product"
            @product = data
            @$location.path("/")
        ,
        (error) =>
            @$log.error "Unable to update Product: #{error}"
      )

  findProduct: () ->
      # route params must be same name as provided in routing url in app.coffee
      productId = @$routeParams.productId
      @$log.debug "findProduct route params: #{productId}"

      @ProductService.listProducts()
      .then(
        (data) =>
          @$log.debug "Promise returned #{data.length} Products"

          # find a product with the name of firstName and lastName
          # as filter returns an array, get the first object in it, and return it
          @product = (data.filter (product) -> product.Id is productId)[0]
      ,
        (error) =>
          @$log.error "Unable to get Products: #{error}"
      )

controllersModule.controller('UpdateProductCtrl', UpdateProductCtrl)