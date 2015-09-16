import jenkins.model.*
import hudson.model.*

def instance = Jenkins.getInstance()
def jdkDescriptor = instance.getDescriptor(JDK)
jdkDescriptor.setInstallations(
        new JDK("JDK7", "/opt/jdk1.7.0_72/"),
)

instance.save()
