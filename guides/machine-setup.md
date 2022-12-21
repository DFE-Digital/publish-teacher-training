# Machine setup

## Prerequisites

You'll need to have the libraries below to be able to develop the application locally. You can install them manually, or using a package manager like [Homebrew](https://brew.sh/). We also have instructions for if you're using ASDF below.


- [Ruby](https://www.ruby-lang.org/en/)
- [Node.js](https://nodejs.org/en/)
- [Yarn](https://yarnpkg.com/)
- [PostgreSQL](https://www.postgresql.org/)
- [Redis](https://redis.io/)
- [ChromeDriver](https://chromedriver.chromium.org/)
- [Terraform](https://www.terraform.io/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Make](https://www.gnu.org/software/make/)
- [JQ](https://stedolan.github.io/jq/)


### Install build dependencies with ASDF

Install [asdf-vm](https://asdf-vm.com/).

Install the plugins and versions specified in `.tool-versions`

```bash
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf install
```

When the versions are updated in main run `asdf install` again to update your
installation.

(We don't mandate asdf, you can use other tools if you prefer.)
