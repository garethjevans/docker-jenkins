import groovy.json.*

def plugins = [:]
new File('plugins.txt').readLines().each{ plugins.put( it.split(':')[0] , it.split(':')[1] ) }

def content = "https://updates.jenkins.io/current/update-center.actual.json".toURL().text

def jsonSlurper = new JsonSlurper()
def meta = jsonSlurper.parseText(content)

meta.plugins.each { k,v -> 
    if (plugins.containsKey(k)) {
        def newVersion = v.version 
        def currentVersion = plugins[k]
        if (newVersion != currentVersion) {
            println "${k} ${currentVersion} -> ${newVersion}"
            plugins[k] = newVersion
            v.dependencies.findAll{ !it.optional }.each {
                if (!plugins.containsKey(it.name)) {
                    println "Missing dependency - ${it.name}:${it.version}" 
                }
            }
        }
    }
}

def sb = new StringBuilder()

plugins.each{ k,v -> 
    sb << "${k}:${v}\n"
}

new File('plugins.txt').text = sb.toString()
