# Using a GitHub App for AWS Amplify Authentication with Terraform

This guide explains how to set up a GitHub App for use with the `aws_amplify_app` Terraform resource, automate token generation with GitHub Actions, and securely pass the token to Terraform.

---

## 1. Create a GitHub App

1. Go to your organization or user **Settings** → **Developer settings** → **GitHub Apps**.
2. Click **New GitHub App**.
3. Fill in:
   - **App name**: e.g., `amplify-terraform-bot`
   - **Homepage URL**: e.g., `https://github.com/<your-org>/<your-repo>`
   - **Callback URL**: Can be blank or your repo URL.
4. **Repository permissions**:
   - **Contents**: Read and write
   - **Metadata**: Read-only
   - **Webhooks**: Read and write
   - **Pull requests**: Read and write
   - **Commit statuses**: Read and write
5. Click **Create GitHub App**.

---

## 2. Install the App

- After creation, click **Install App** (left sidebar).
- Install it on your organization or the specific repository you want Amplify to access.

---

## 3. Generate and Save App Credentials

- On the app page, click **Generate a private key**. Download and save the `.pem` file.
- Note the **App ID** (shown on the app page).

---

## 4. Add Secrets to GitHub Repository

Go to your repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

- `GH_APP_ID`: Your GitHub App’s App ID (number)
- `GH_APP_PRIVATE_KEY`: Paste the contents of your `.pem` file

---

## 5. Update Your Terraform Workflow

Add a step to generate the installation token using [`tibdex/github-app-token`](https://github.com/tibdex/github-app-token), and pass it to Terraform as `TF_VAR_gh_access_token`.

Example `.github/workflows/terraform.yml`:

```yaml
name: Terraform

on:
  push:
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'
  pull_request:
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Generate GitHub App installation token
        id: generate_token
        uses: tibdex/github-app-token@v2
        with:
          app_id: ${{ secrets.GH_APP_ID }}
          private_key: ${{ secrets.GH_APP_PRIVATE_KEY }}

      - name: Terraform Init
        run: terraform init
        working-directory: ./terraform

      - name: Terraform Plan
        env:
          TF_VAR_gh_access_token: ${{ steps.generate_token.outputs.token }}
        run: terraform plan
        working-directory: ./terraform

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        env:
          TF_VAR_gh_access_token: ${{ steps.generate_token.outputs.token }}
        run: terraform apply -auto-approve
        working-directory: ./terraform
```

---

## 6. Verify Your Terraform Code

Ensure your Terraform configuration uses the `gh_access_token` variable for the `aws_amplify_app` resource:

```hcl
resource "aws_amplify_app" "website" {
  # ...
  access_token = var.gh_access_token
  # ...
}
```

---

## 7. Commit and Push

Commit your workflow changes and push to GitHub. The workflow will now generate a GitHub App installation token and use it for AWS Amplify authentication.

---

**Security Note:**  
Never commit your private key or tokens to version control. Always use GitHub Secrets.