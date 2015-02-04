package models

object JsonFormats {
  import play.api.libs.json.Json

  implicit val productFormat = Json.format[Product]
}
