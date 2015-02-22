class CatalogCtrl
    constructor: (@$log, @ProductService) ->
        @$log.debug "constructing CatalogController"
        @products = []
        @getAllProducts()
        @selected = ""
        @hints = []
        @product = {
                     "Id": null,
                     "Title": null,
                     "Price": null,
                     "Cost": null
                   }

    onSelect: ($item, $model, $label) ->
        @$log.debug "onSelect() selected: " + @selected
        selectedProduct = null
        if isFinite($item)
            selectedProduct = @findProductById($item)
            @$log.debug "Found product by id: " + angular.toJson(selectedProduct)
        if !selectedProduct
            selectedProduct = @findProductByTitle($item)
            @$log.debug "Found product by title: " + angular.toJson(selectedProduct)
        if !selectedProduct
            @$log.error "Couldn't find a product with id or title: " + $item
            return
        @product = {
                     "Id": selectedProduct.Id,
                     "Title": selectedProduct.Title,
                     "Price": selectedProduct.Price.toString(),
                     "Cost": selectedProduct.Cost.toString()
                   }

    updateTitleOrId: ()->
        @$log.debug "updateTitleOrId() selected: " + @selected

    findProductById: ($id) ->
        #@outputState(@products, @hints)
        for p in @products
            return p if p.Id == $id
        @$log.debug "Couldn't find product id: " + $id
        return null

    findProductByTitle: ($title) ->
        #@outputState(@products, @hints)
        for p in @products
            return p if p.Title == $title
        @$log.debug "Couldn't find product title: " + $title
        return null

    outputState: ($products, $hints) ->
        @$log.debug "state:"
        for product in $products
            @$log.debug "--product: " + angular.toJson(product)
        for hint in $hints
            @$log.debug "--hint: " + angular.toJson(hint)

    regenerateHints: () ->
        @hints = []
        tmp = []
        for p in @products
            tmp.push p.Id
            tmp.push p.Title
        if tmp.length == 0
            return
        tmp.sort()
        for i in [1..tmp.length]
            if(tmp[i] != tmp[i-1])
                @hints.push(tmp[i-1])

    getAllProducts: () ->
        @$log.debug "getAllProducts()"

        @ProductService.listProducts()
        .then(
            (data) =>
                @$log.debug "Promise returned #{data.length} Products"
                @products = data
                @regenerateHints()
            ,
            (error) =>
                @$log.error "Unable to get Products: #{error}"
            )

    validateProduct: ( $product )->
        #normalize product
        res = {
             "Id": if ( $product.Id? ) then $product.Id.replace /^\s+|\s+$/g else "",
             "Title": if ( $product.Title? ) then $product.Title.replace /^\s+|\s+$/g else "",
             "Price": if ( $product.Price? ) then $product.Price.replace /^\s+|\s+$/g else "",
             "Cost": if ( $product.Cost? ) then $product.Cost.replace /^\s+|\s+$/g else ""
           }

        if res.Id.length == 0
            alert( "Id is empty" )
            return null

        if !res.Id.match(/[0-9]+/)
            alert( "Please use numeric Id: " + res.Id )
            return null

        if res.Title.length == 0
            alert( "Title is empty" )
            return null
        if !res.Title.match(/[a-zA-Z0-9]/)
            alert( "Please use alpha-numeric Title" )
            return null

        if res.Price.length == 0
            alert( "Price is empty" )
            return null

        if !isFinite(res.Price)
            alert( "Price is not a number" )
            return null

        res.Price = parseFloat(res.Price)
        if res.Price <= 0
            alert( "Please use positive Price" )
            return null

        if res.Cost.length == 0
            alert( "Cost is empty" )
            return null

        if !isFinite(res.Cost)
            alert( "Cost is not a number" )
            return null

        res.Cost = parseFloat(res.Cost)
        if res.Cost <= 0
            alert( "Please use positive Cost" )
            return null

        if res.Price <= res.Cost
            alert( "Cost should be less then Price" )
            return null
        return res

    submitProduct: () ->
        @$log.debug "submitProduct: " + angular.toJson(@product)
        #@outputState(@products, @hints)
        validProduct = @validateProduct( @product )
        if validProduct == null
            return
        oldProduct = @findProductById(validProduct.Id)
        @$log.debug "oldProduct: " + angular.toJson(oldProduct)
        if oldProduct
            isChanged =
                oldProduct.Title != validProduct.Title ||
                oldProduct.Price != validProduct.Price ||
                oldProduct.Cost != validProduct.Cost
            if !isChanged
                @$log.debug "Can't update product. It hasn't been changed: " + angular.toJson(validProduct)
                return
            @updateProduct(oldProduct, validProduct)
        else
            @createProduct(validProduct)

    updateProduct: ( $oldProduct, $newProduct ) ->
        @$log.debug "updateProduct( $oldProduct: " + angular.toJson($oldProduct) + ", $newProduct: " + angular.toJson($newProduct) + " )"
        @ProductService.updateProduct($newProduct.Id, $newProduct)
        .then(
            (data) =>
                @$log.debug "Promise returned #{data} Product"
                $oldProduct.Cost = $newProduct.Cost
                $oldProduct.Price = $newProduct.Price
                if $oldProduct.Title != $newProduct.Title
                    $oldProduct.Title = $newProduct.Title
                    @regenerateHints()
                alert( "Product has been updated: " + angular.toJson($newProduct) )
        (error) =>
            @$log.error "Unable to update Product: #{error}"
            alert( "Couldn't update product: " + angular.toJson($newProduct) )
        )

    createProduct: ( $newProduct ) ->
        @$log.debug "createProduct: " + angular.toJson($newProduct)

        @ProductService.createProduct($newProduct)
        .then(
            (data) =>
                @$log.debug "Promise returned: #{data}"
                @products.push($newProduct)
                @hints.push($newProduct.Id)
                if !@findProductByTitle($newProduct.Title)
                    @hints.push($newProduct.Title)
                alert( "Product has been created: " + angular.toJson($newProduct) )
            ,
            (error) =>
                @$log.error "Unable to create Product: #{error}"
                alert( "Couldn't create product: " + angular.toJson($newProduct) )
            )

    validateProductId: ( $id )->
        id = if ( $id? ) then $id.replace /^\s+|\s+$/g else ""
        if id.length == 0
            alert( "Id is empty" )
            return null
        if !id.match(/[0-9]+/)
            alert( "Please use numeric Id: " + id )
            return null
        return id

    removeProduct: () ->
        @$log.debug "removeProduct() id: " + @product.Id

        validId = @validateProductId( @product.Id )
        if validId == null
            return
        oldProduct = @findProductById(validId)
        @$log.debug "oldProduct: " + angular.toJson(oldProduct)
        if oldProduct
            @ProductService.removeProduct(oldProduct)
            .then(
                (data) =>
                    @$log.debug "Promise returned: #{data}"
                    alert( "Product has been removed: " + angular.toJson(oldProduct) )
                    index = @products.indexOf(oldProduct)
                    if( index > -1 )
                        @products.splice(index, 1)
                        @regenerateHints()
                    @product = {
                                 "Id": null,
                                 "Title": null,
                                 "Price": null,
                                 "Cost": null
                               }
            (error) =>
                @$log.error "Unable to update Product: #{error}"
                alert( "Couldn't remove product: " + angular.toJson(oldProduct) )
            )
        else
            alert("Can't remove product id: " + validId + " because it doesn't exist")

controllersModule.controller('CatalogCtrl', CatalogCtrl)