# Prototype branches

We branch off the `main` branch of this repository to build prototype branches. Prototype branches must be prefixed with `prototype/` in order to be deployed.

## What are "prototype" branches?

Prototype branches are forks of the code that are built primarily by the team's Interaction Designer. Their purpose is to provide a near-to live service experience for experimental and upcoming designs.

The benefits of using the Rails codebase to prototype are:

- It already provides a foundation for the service's existing functionality. There is no need to build the results page, for example.
- As developers are already familiar with the language and codebase, they are available to assist with development and troubleshooting.

The drawbacks, compared to Figma and the GOV.UK Prototype kit, are:

- Branches need to be compatible to merge with the `main` branch in order to be deployable. This means that conflicts need to be resolved.
- As developers are not familiar with the tooling, language nor codebase, the Interaction Designer will receive limited support from the internal team.

## Deploying prototype branches

> [!IMPORTANT]
> The deployment workflow will only trigger if the branch name is prefixed with `prototype/` and the `prototype` label has been attached.

To deploy a prototype branch, open a PR and add the `prototype` label to it. The `prototype` label bypasses any code quality checks and directly deploys the review app, if possible. The code will redeploy itself on all new code pushes.

Once deployment is successful, a comment will be posted to the PR linking to the relevant review app URLs.

### Example PRs

- [prototype/provider-performance](https://github.com/DFE-Digital/publish-teacher-training/pull/5066)
- [prototype/structure-course-information](https://github.com/DFE-Digital/publish-teacher-training/pull/5221)
