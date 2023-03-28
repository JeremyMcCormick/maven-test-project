# Maven Test Project

## Overview

This project includes a workflow defined in `.github/workflows/release.yml` for releasing a Maven project using Github Actions. A release will be automatically triggered whenever a tag is pushed to the repository that looks like `"releases/**"`. An example tag name could be `releases/workshop2023`. The name of the tag is arbitrary and does not have to match the versions in Maven. The workflow will manage the versioning and release tags based on what is in the project's POM. A Maven release is performed and a Github release page is also created with automatically generated release notes. A tag is created in the repository for the release e.g. `maven-git-test-1.0.0`. The patch version in the project's `pom.xml` is automatically updated (1.0.0 -> 1.0.1-SNAPSHOT).

The bin jar file should be uploaded to Nexus and accessible via a public URL like:

```
https://srs.slac.stanford.edu/nexus/repository/lcsim-maven2-releases/org/hps/maven-test-project/1.0.2/maven-test-project-1.0.2-bin.jar
```

The bin jar is also attached to the Github release page as an artifact, along with the source code.

## Configuration

The write permissions for the release are allowed using a dedicated deployment key within the project settings. 

An SSH key pair was created using this command:

```
ssh-keygen -b 2048 -t rsa -f id_rsa -q -N "" -C "git@github.com:JeremyMcCormick/maven-test-project.git"
```

The public key was added as the deployment key called `SSH_PUBLIC_KEY` under _Settings -> Deploy keys_ in the project. A corresponding repository secret containing the private key was added as `SSH_PRIVATE_KEY`. The private key is then setup in the workflow using the following action:

```
- uses: webfactory/ssh-agent@v0.7.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
```

This deployment key pair should _not_ be reused for any other projects.

The Github user for signing commits during the release is configured as follows:

```
- name: Configure Git User
        run: |
          git config user.email "jermccormick@gmail.com"
          git config user.name "JeremyMcCormick"
```

It should be possible to set this to any Github username and email.

The source control management (SCM) information is defined in the project's POM file as follows:

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

## Release Workflow

The Maven release is performed as follows:

```
- name: Perform Maven release
        run: mvn release:prepare release:perform -B -e -s .maven_settings.xml
        env:
          CI_DEPLOY_USERNAME: ${{ secrets.CI_DEPLOY_USERNAME }}
          CI_DEPLOY_PASSWORD: ${{ secrets.CI_DEPLOY_PASSWORD }}
 ```

The `CI_DEPLOY_USERNAME` and `CI_DEPLOY_PASSWORD` are respectively the username and password for uploading jars to the Maven repository. They are defined as repository secrets. These variables are then injected into Maven via the settings file `.maven_settings.xml` within the project, which contains:

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

Finally, the Github release is made as follows:

```
- name: Make Github release
  id: github_release
  uses: softprops/action-gh-release@v1
  with:
    tag_name: ${{ github.event.repository.name }}-${{ env.MAVEN_RELEASE_VERSION }}
    name: ${{ github.event.repository.name }} ${{ env.MAVEN_RELEASE_VERSION }}
    generate_release_notes: true
    draft: false
    prerelease: false
    files: |
      ./target/${{ github.event.repository.name }}-${{ env.MAVEN_RELEASE_VERSION }}-bin.jar
```

An example release can be found [https://github.com/JeremyMcCormick/maven-test-project/releases/tag/maven-test-project-1.0.15](here).

## Triggering a Release

The release process is triggered by pushing a tag that starts with "releases/" to the Github repository.

For instance, all of these would be valid tags:

- releases/reltest1
- releases/prod2023
- releases/v1.2.3

The release tag itself is only used for checking out the correct version of the source code, so it does not need to follow any specific naming convention. The actual versioned tags for the release are created by Maven based on information in the POM file. For instance, if the POM file contained "1.0.0-SNAPSHOT" then the tag for the release would be called "maven-test-project-1.0.0" and the development (snapshot) version would be incremented to "1.0.1-SNAPSHOT" automatically. Major and minor tags should be incremented manually by updating the POM file.

This is an example of creating a tag locally:

```
git tag -a releases/reltest1 -m "rel test 1"
```

The local tag then needs to be pushed to trigger the release:

```
git push origin releases/reltest1
```

Only the project release manager should push tags to trigger the release workflow.

## TODO List

- Build and deploy the project website to gh pages.
