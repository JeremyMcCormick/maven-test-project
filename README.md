# Maven Test Project

This project includes a workflow defined in `.github/workflows/release.yml` for releasing a Maven project using Github Actions. 

An SSH key was created using this command:

```
ssh-keygen -b 2048 -t rsa -f id_rsa -q -N "" -C "git@github.com:JeremyMcCormick/maven-test-project.git"
```

The SCM is defined in the project's POM file as follows:

```
<scm>
    <url>git@github.com:JeremyMcCormick/maven-test-project.git</url>
    <connection>scm:git:${project.scm.url}</connection>
    <developerConnection>scm:git:${project.scm.url}</developerConnection>
    <tag>HEAD</tag>
  </scm>

  <properties>
    <project.scm.id>github</project.scm.id>
  </properties>
```

(Not sure if the property setting is needed???)

The public key was then added as a deployment key (under Settings -> Deploy keys in the project) called `SSH_PUBLIC_KEY`. A corresponding repository secret containing the private key was added as `SSH_PRIVATE_KEY`. The private key is then setup in the workflow using the following step:

```
- uses: webfactory/ssh-agent@v0.7.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
```

The Github user is configured as follows:

```
- name: Configure Git User
        run: |
          git config user.email "jermccormick@gmail.com"
          git config user.name "JeremyMcCormick"
```

It should be possible to set this to any valid Github username and email (preferable to use a bot account here).

The actual release is performed as follows:

```
- name: Cut HPS Java Release
        run: mvn release:prepare release:perform -B -e -s .maven_settings.xml
        env:
          CI_DEPLOY_USERNAME: ${{ secrets.CI_DEPLOY_USERNAME }}
          CI_DEPLOY_PASSWORD: ${{ secrets.CI_DEPLOY_PASSWORD }}
 ```

The `CI_DEPLOY_USERNAME` and `CI_DEPLOY_PASSWORD` are respectively the username and password for uploading jars to the Maven repository. These variables are then injected into Maven via the settings file `.maven_settings.xml` in the project, which contains:

```
<servers>
    <server>
        <id>lcsim-repo-releases</id>
        <username>${env.CI_DEPLOY_USERNAME}</username>
        <password>${env.CI_DEPLOY_PASSWORD}</password>
    </server>
    <server>
        <id>lcsim-repo-snapshots</id>
        <username>${env.CI_DEPLOY_USERNAME}</username>
        <password>${env.CI_DEPLOY_PASSWORD}</password>
    </server>
</servers>
```

For demonstration purposes, the release triggers on any update to the `master` branch. This can be configured to trigger on any pattern or string (e.g. `releases/**` for production). A tag is created in the repository for the release e.g. `maven-git-test-1.0.0`. The patch version in the project's `pom.xml` is automatically updated (1.0.0 -> 1.0.1-SNAPSHOT). 

The bin jar file should be uploaded to Nexus and accessible via a public URL like:

```
https://srs.slac.stanford.edu/nexus/repository/lcsim-maven2-releases/org/hps/maven-test-project/1.0.2/maven-test-project-1.0.2-bin.jar
```

The release itself within Github needs to be made manually by selecting the tag that was created in the dropdown.

TODO List

- Change the trigger to something sensible like tags which match `releases/**` or `v**`.
- The bin jar should be automatically attached to the release by downloading it from Nexus in a post-release workflow.
- Build and deploy the project website to gh pages.
