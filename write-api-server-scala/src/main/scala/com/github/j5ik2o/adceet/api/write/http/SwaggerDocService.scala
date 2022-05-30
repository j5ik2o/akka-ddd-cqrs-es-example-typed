package com.github.j5ik2o.adceet.api.write.http

import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server.Route
import ch.megard.akka.http.cors.scaladsl.CorsDirectives
import ch.megard.akka.http.cors.scaladsl.settings.CorsSettings
import com.github.swagger.akka.{ model, SwaggerGenerator }
import com.sun.org.apache.xml.internal.utils.ThreadControllerWrapper.ThreadController

class SwaggerDocService(private val host: String, private val port: Int) {

  val generator = new SwaggerGenerator() {

    override def apiClasses: Set[Class[_]] = Set(
      classOf[ThreadController]
    )

    override def schemes: List[String] = List("http")

    override def host: String = s"$host:$port"

    override def apiDocsPath: String = "api-docs"

    override def info: model.Info = {
      val info = model.Info()
      info.setTitle("thread service api")
      info.setVersion("v1")
      info
    }
  }

  def toRoute(): Route = {
    val route: Route = concat(
      path("swagger") {
        getFromResource("swagger/index.html")
      },
      getFromResourceDirectory("swagger"),
      path(
        generator.apiDocsPath / "swagger.json"
      ) { get { complete(generator.generateSwaggerJson) } }
    )

    val settings: CorsSettings = CorsSettings.defaultSettings
    CorsDirectives.cors(settings) { route }
  }
}