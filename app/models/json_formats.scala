package models

object JsonFormats {
  import play.api.libs.json.Json

  // Generates Writes and Reads for Product and User thanks to Json Macros
  implicit val userFormat = Json.format[User]
  implicit val productFormat = Json.format[Product]
}
