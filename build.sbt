import Dependencies._
import net.moznion.sbt.spotless.config.{ KotlinConfig, KtlintConfig }

lazy val root = (project in file("."))
  .settings(
    Settings.baseSettings,
    name := "adceet-root"
  ).aggregate(`write-api-server-kt`)

lazy val `write-api-server-kt` = (project in file("write-api-server-kt"))
  .enablePlugins(JavaAgent, JavaAppPackaging, EcrPlugin, MultiJvmPlugin)
  .configs(MultiJvm)
  .settings(
    Settings.baseSettings,
    Settings.multiJvmSettings,
    Settings.dockerCommonSettings,
    Settings.ecrSettings
  )
  .settings(
    name := "adceet-write-api-server-kt",
    Compile / run / mainClass := Some("example.api.Main"),
    dockerEntrypoint := Seq(s"/opt/docker/bin/${name.value}"),
    dockerExposedPorts := Seq(8081, 8558, 25520),
    javaAgents += "io.kamon" % "kanela-agent" % "1.0.14",
    run / javaOptions ++= Seq(
      s"-Dcom.sun.management.jmxremote.port=${sys.env.getOrElse("JMX_PORT", "8999")}",
      "-Dcom.sun.management.jmxremote.authenticate=false",
      "-Dcom.sun.management.jmxremote.ssl=false",
      "-Dcom.sun.management.jmxremote.local.only=false",
      "-Dcom.sun.management.jmxremote",
      "-Xms1024m",
      "-Xmx1024m",
      "-Djava.library.path=./target/native"
    ),
    Universal / javaOptions ++= Seq(
      "-Dcom.sun.management.jmxremote",
      "-Dcom.sun.management.jmxremote.local.only=true",
      "-Dcom.sun.management.jmxremote.authenticate=false",
      "-Dorg.aspectj.tracing.factory=default"
    ),
    libraryDependencies ++= Seq(
      airframe.ulid,
      logback.logbackClassic,
      arrowKt.arrowCore,
      vavr.varKotlin,
      kodeinDI.kodeinDIJvm,
      kotlinx.coroutinesCoreJvm,
      xenomachina.kotlinArgParser,
      jakarta.rsApi,
      swaggerAkkaHttp.swaggerAkkaHttp,
      megard.akkaHttpCors,
      typesafeAkka.akkaHttp,
      typesafeAkka.akkaHttpSprayJson,
      typesafeAkka.akkaHttpJackson,
      typesafeAkka.akkaSlf4j,
      typesafeAkka.akkaActorTyped,
      typesafeAkka.akkaStreamTyped,
      typesafeAkka.akkaClusterTyped,
      typesafeAkka.akkaClusterShardingTyped,
      typesafeAkka.akkaPersistenceTyped,
      typesafeAkka.akkaSerializationJackson,
      typesafeAkka.akkaDiscovery,
      lightbend.akkaManagement,
      lightbend.akkaManagementClusterHttp,
      lightbend.akkaManagementClusterBootstrap,
      lightbend.akkaDiscoveryAwsApiAsync,
      fasterXmlJackson.scala,
      fasterXmlJackson.kotlin,
      j5ik2o.akkaPersistenceDynamoDBJournal,
      j5ik2o.akkaPersistenceDynamoDBSnapshot,
      kamon.core,
      kamon.statusPage,
      kamon.akka,
      kamon.akkaHttp,
      kamon.systemMetrics,
      kamon.logback,
      kamon.datadog,
      aichler.jupiterInterface(JupiterKeys.jupiterVersion.value) % Test,
      scalatest.scalatest                                        % Test,
      jupiter.jupiterApi                                         % Test,
      jupiter.jupiter                                            % Test,
      jupiter.jupiterMigrationSupport                            % Test,
      kotlinx.coroutinesTest                                     % Test,
      mockk.mockk                                                % Test,
      typesafeAkka.actorTestkitTyped                             % Test,
      typesafeAkka.streamTestkit                                 % Test,
      typesafeAkka.httpTestkit                                   % Test,
      typesafeAkka.multiNodeTestkit                              % Test,
      awaitility.awaitility                                      % Test,
      commonsIO.commonsIO                                        % Test,
      // テストでは使っていないので削除してもよい
      fusesource.leveldbjniAll % Test,
      iq80LevelDb.leveldb      % Test
    ),
    spotlessKotlin := KotlinConfig(
      target = Seq("src/**/*.kt", "test/**/*.kt"),
      ktlint = KtlintConfig(version = "0.40.0", userData = Map("indent_size" -> "2", "continuation_indent_size" -> "2"))
    ),
    Test / publishArtifact := false,
    run / fork := false,
    Test / parallelExecution := false,
    Global / cancelable := false
  )

// --- Custom commands
addCommandAlias("lint", ";spotlessCheck;scalafmtCheck;test:scalafmtCheck;scalafmtSbtCheck")
addCommandAlias("fmt", ";spotlessApply;scalafmtAll;scalafmtSbt")
