import jenkins.model.*
import hudson.tasks.*

def instance = Jenkins.getInstance()
def mvnDescriptor = instance.getDescriptor(Maven)
mvnDescriptor.setInstallations(
        new Maven.MavenInstallation("3.2.2", "/opt/apache-maven-3.2.2")
)

instance.save()
