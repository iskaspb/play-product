class CatalogCtrl
    constructor: (@$log, @ProductService) ->
        @$log.debug "constructing CatalogController"
        @products = []
        @getAllProducts()
        @selected = ""
        @hints = []
        @product = null

    onSelect: ($item, $model, $label) ->
        @$log.debug "onSelect() selected: " + @selected
        selectedProduct = null
        if isFinite($item)
            selectedProduct = @findProductById($item)
            @$log.debug "Found product by id: " + angular.toJson(selectedProduct)
        if !selectedProduct
            selectedProduct = @findProductByTitle($item)
            @$log.debug "Found product by title: " + angular.toJson(selectedProduct)
        @product = selectedProduct
        if !@product
            @$log.warning "Couldn't find a product with id or title: " + $item

    updateTitleOrId: ()->
        @$log.debug "updateTitleOrId() selected: " + @selected

    findProductById: ($id) ->
        (i for i in @products when i.Id is $id)[0]

    findProductByTitle: ($title) ->
        (i for i in @products when i.Title is $title)[0]

    getAllProducts: () ->
        @$log.debug "getAllProducts()"

        @ProductService.listProducts()
        .then(
            (data) =>
                @$log.debug "Promise returned #{data.length} Products"
                @products = data
                for p in data
                    @hints.push p.Id
                    @hints.push p.Title
            ,
            (error) =>
                @$log.error "Unable to get Products: #{error}"
            )

    submitProduct: () ->
        @$log.debug "selected: " + @selected
        @$log.debug "submitProduct: " + angular.toJson(@product)
        #TODO: validate fields (empty, numerics)
        if @product.Id
            @updateProduct
            #TODO: on success -> if Title is changed -> update list of products and regenerate hints
        else
            #TODO: create new ID
            @$log.debug 'createProduct()'
            #TODO: on success -> add this product to the list of products and regenerate hints

    updateProduct: () ->
        @$log.debug "updateProduct()"
        @ProductService.updateProduct(@product.Id, @product)
        .then(
            (data) =>
                @$log.debug "Promise returned #{data} Product"
                @product = data
                @$location.path("/")
        ,
        (error) =>
            @$log.error "Unable to update Product: #{error}"
        )


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

controllersModule.controller('CatalogCtrl', CatalogCtrl)