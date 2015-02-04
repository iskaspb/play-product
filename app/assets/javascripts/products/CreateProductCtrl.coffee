
class CreateProductCtrl

    constructor: (@$log, @$location,  @ProductService) ->
        @$log.debug "constructing CreateProductController"
        @product = {}

    createProduct: () ->
        @$log.debug "createProduct()"
        @ProductService.createProduct(@product)
        .then(
            (data) =>
                @$log.debug "Promise returned #{data} Product"
                @product = data
                @$location.path("/")
            ,
            (error) =>
                @$log.error "Unable to create Product: #{error}"
            )

controllersModule.controller('CreateProductCtrl', CreateProductCtrl)