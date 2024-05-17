docker.io/initializ-buildpacks/apache-tomcat

The Initializ Buildpack for Apache Tomcat is a Cloud Native Buildpack designed to seamlessly integrate Apache Tomcat and Process Types for WARs into your deployment pipeline.

Overview
This buildpack automatically detects and configures Apache Tomcat for your Java applications. It ensures that your WAR files are efficiently deployed and managed within a Tomcat environment.

How it Works
Conditions for Participation
For this buildpack to take effect, the following conditions must be met:

$BP_JAVA_APP_SERVER is set to tomcat, or it's unset/empty, and this buildpack is the first to provide a Java application server.
The <APPLICATION_ROOT>/WEB-INF directory exists.
The manifest file does not define Main-Class.
Behavior
Once activated, the buildpack performs the following tasks:

Requests installation of a JRE.
Adds Apache Tomcat to both $CATALINA_HOME and $CATALINA_BASE.
Includes essential configuration files like context.xml, logging.properties, server.xml, and web.xml under conf/.
Integrates [Access Logging Support][als], [Lifecycle Support][lcs], and [Logging Support][lgs].
Optionally incorporates external configurations if provided.
Defines process types such as tomcat, task, and web.
Tiny Stack Considerations
When operating within the Tiny stack, certain limitations and adjustments apply:

Absence of a shell precludes the use of catalina.sh for starting Tomcat.
Tomcat startup commands are generated directly, with some functionality limitations compared to catalina.sh.
Configuration options like bin/setenv.sh and CATALINA_* environment variables are unavailable.
Tomcat runs with a umask set to 0022 instead of the default 0027 in catalina.sh.
Configuration
This buildpack offers several environment variables for fine-tuning:

Environment Variable	Description
$BP_JAVA_APP_SERVER	Specifies the application server to use. Defaults to `` (empty string), allowing the buildpack order to dictate the installed Java application server.
$BP_TOMCAT_CONTEXT_PATH	Sets the context path for mounting the application. Defaults to empty (ROOT).
$BP_TOMCAT_EXT_CONF_SHA256	SHA256 hash of the external configuration package.
$BP_TOMCAT_ENV_PROPERTY_SOURCE_DISABLED	Disables configuration of org.apache.tomcat.util.digester.EnvironmentPropertySource when set to true. Useful for loading configuration from environment variables and referencing them in Tomcat configuration files.
$BP_TOMCAT_EXT_CONF_STRIP	Specifies the number of directory levels to strip from the external configuration package. Defaults to 0.
$BP_TOMCAT_EXT_CONF_URI	Sets the download URI for the external configuration package.
$BP_TOMCAT_EXT_CONF_VERSION	Specifies the version of the external configuration package.
$BP_TOMCAT_VERSION	Sets a specific Tomcat version. The value must exactly match an available version in the buildpack. Typically configured with a wildcard such as 9.*.
BPL_TOMCAT_ACCESS_LOGGING_ENABLED	Enables access logging. Defaults to inactive.
BPI_TOMCAT_ADDITIONAL_JARS	Allows inclusion of additional JARs to the Tomcat classpath. Multiple JARs should be separated by :.
External Configuration Package
When providing external configurations, ensure they adhere to the following TAR format:

markdown
Copy code
<CATALINA_BASE>
└── conf
    ├── context.xml
    ├── server.xml
    ├── web.xml
    ├── ...
Environment Property Source
Enabling the Environment Property Source allows loading Tomcat's configuration files from environment variables, enhancing flexibility and ease of management.

Bindings
Optionally, the buildpack can accept the following bindings:

Type: dependency-mapping
Key	Value	Description
<dependency-digest>	<uri>	Fetches the dependency with digest <dependency-digest> from <uri> if needed.
Providing Additional JARs to Tomcat
Buildpacks can contribute JARs to Tomcat's CLASSPATH by appending paths to BPI_TOMCAT_ADDITIONAL_JARS.

go
Copy code
// Example function to contribute additional JARs
func (s) Contribute(layer libcnb.Layer) (libcnb.Layer, error) {
	// Copy dependency into the layer
	file := filepath.Join(layer.Path, filepath.Base(s.Dependency.URI))

	layer, err := s.LayerContributor.Contribute(layer, func(artifact *os.File) (libcnb.Layer, error) {
		if err := sherpa.CopyFile(artifact, file); err != nil {
			return libcnb.Layer{}, fmt.Errorf("unable to copy artifact to %s\n%w", file, err)
		}
		return layer, nil
	})

	additionalJars := []string{file}
  // Add dependency to BPI_TOMCAT_ADDITIONAL_JARS
	layer.LaunchEnvironment.Append("BPI_TOMCAT_ADDITIONAL_JARS", ":", strings.Join(additionalJars, ":"))
	return layer, nil
}
License
This buildpack is released under version 2.0 of the Apache License.