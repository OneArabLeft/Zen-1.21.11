open('settings.gradle','w').write(
'pluginManagement {\n'
'    repositories {\n'
'        maven { name = \'Fabric\'; url = \'https://maven.fabricmc.net/\' }\n'
'        mavenCentral()\n'
'        gradlePluginPortal()\n'
'    }\n'
'}\n'
)

open('build.gradle','w').write(
'plugins { id \'fabric-loom\' version \'1.7-SNAPSHOT\' }\n'
'version = \'1.0.0\'\n'
'group = \'com.sct\'\n'
'base { archivesName = \'slayer-carry-tracker\' }\n'
'repositories {}\n'
'dependencies {\n'
'    minecraft \'com.mojang:minecraft:1.21.1\'\n'
'    mappings \'net.fabricmc:yarn:1.21.1+build.3:v2\'\n'
'    modImplementation \'net.fabricmc:fabric-loader:0.16.5\'\n'
'    modImplementation \'net.fabricmc.fabric-api:fabric-api:0.102.0+1.21.1\'\n'
'}\n'
'loom {\n'
'    splitEnvironmentSourceSets()\n'
'    mods { sct { sourceSet sourceSets.main; sourceSet sourceSets.client } }\n'
'}\n'
'java {\n'
'    sourceCompatibility = JavaVersion.VERSION_21\n'
'    targetCompatibility = JavaVersion.VERSION_21\n'
'}\n'
'tasks.withType(JavaCompile).configureEach { it.options.release = 21 }\n'
)
print('Gradle files written OK')
