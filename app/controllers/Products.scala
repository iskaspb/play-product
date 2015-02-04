package controllers

import javax.inject.Singleton

import org.slf4j.{Logger, LoggerFactory}
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.json._
import play.api.mvc._
import play.modules.reactivemongo.MongoController
import play.modules.reactivemongo.json.collection.JSONCollection
import reactivemongo.api.Cursor

import scala.concurrent.Future

/**
 * The Products controllers encapsulates the Rest endpoints and the interaction with the MongoDB, via ReactiveMongo
 * play plugin. This provides a non-blocking driver for mongoDB as well as some useful additions for handling JSon.
 * @see https://github.com/ReactiveMongo/Play-ReactiveMongo
 */
@Singleton
class Products extends Controller with MongoController {

  private final val logger: Logger = LoggerFactory.getLogger(classOf[Products])

  /*
   * Get a JSONCollection (a Collection implementation that is designed to work
   * with JsObject, Reads and Writes.)
   * Note that the `collection` is not a `val`, but a `def`. We do _not_ store
   * the collection reference to avoid potential problems in development with
   * Play hot-reloading.
   */
  def collection: JSONCollection = db.collection[JSONCollection]("products")

  // ------------------------------------------ //
  // Using case classes + Json Writes and Reads //
  // ------------------------------------------ //

  import models.JsonFormats._
  import models._

  def createProduct = Action.async(parse.json) {
    request =>
    /*
     * request.body is a JsValue.
     * There is an implicit Writes that turns this JsValue as a JsObject,
     * so you can call insert() with this JsValue.
     * (insert() takes a JsObject as parameter, or anything that can be
     * turned into a JsObject using a Writes.)
     */
      request.body.validate[Product].map {
        product =>
        // `product` is an instance of the case class `models.Product`
          collection.insert(product).map {
            lastError =>
              logger.debug(s"Successfully inserted with LastError: $lastError")
              Created(s"Product Created")
          }
      }.getOrElse(Future.successful(BadRequest("invalid json")))
  }

  def updateProduct(productId: String) = Action.async(parse.json) {
    request =>
      request.body.validate[Product].map {
        product =>
          // find our product by productId
          val nameSelector = Json.obj("Id" -> productId)
          collection.update(nameSelector, product).map {
            lastError =>
              logger.debug(s"Successfully updated with LastError: $lastError")
              Created(s"Product Updated")
          }
      }.getOrElse(Future.successful(BadRequest("invalid json")))
  }

  def findProducts = Action.async {
    // let's do our query
    val cursor: Cursor[Product] = collection.
      // find all
      //find(Json.obj("active" -> true)).
      genericQueryBuilder.
      // sort them by creation date
      sort(Json.obj("created" -> -1)).
      // perform the query and get a cursor of JsObject
      cursor[Product]

    // gather all the JsObjects in a list
    val futureProductsList: Future[List[Product]] = cursor.collect[List]()

    // transform the list into a JsArray
    val futureProductsJsonArray: Future[JsArray] = futureProductsList.map { products =>
      Json.arr(products)
    }
    // everything's ok! Let's reply with the array
    futureProductsJsonArray.map {
      products =>
        Ok(products(0))
    }
  }


}
