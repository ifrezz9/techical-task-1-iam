
# IAM Roles — Stage 2 (Quick Guide)

This module creates IAM roles and attaches permission policies in a flexible, data‑driven way.  
All configuration is defined in `locals.tf`, and logic is handled by two modules:

- **iam-roles** — creates the IAM roles  
- **iam-role-policies** — creates & attaches IAM policies  

This is the second stage of the IAM baseline setup.

---

## What Stage 2 Does

In AWS account **000000000000**, this configuration creates:

### **roleA**
- Admin‑level role  
- Access to all AWS services **except IAM**  
- Trust policy allowing the local account root to assume it  

### **roleB**
- Service role  
- Allowed to `sts:AssumeRole` into **roleC** in external account **1111111111**  
- Trusted by the local account root  

All behavior is controlled by the IAM model defined in `locals.tf`.

---

## Important Files

### **1. locals.tf**
Defines the data model for roles:

- **roles** — list of IAM roles to create  
- **external_assume** — list of external roles that local roles can assume  
- **default_role_tags** — common tags applied to all roles  

Edit this file when you want to:
- Add or remove roles  
- Modify role descriptions or paths  
- Allow roles to assume external roles  

---

### **2. main.tf**
This file connects the data model to modules. It:

- Builds trust policies  
- Defines permission policy sets  
- Maps policy sets to the appropriate roles  
- Calls the modules:
  - `iam-roles`
  - `iam-role-policies`

You usually do **not** need to modify this file unless you want to introduce new policy logic.

---

## Modules

### **modules/iam-roles**
Responsible for creating IAM roles.

Inputs:
- Role name  
- Description  
- Trust (assume-role) policy  
- Path  
- Max session duration  
- Tags  

Outputs:
- ARNs of created IAM roles  

---

### **modules/iam-role-policies**
Handles policy management:

- Creates custom IAM policies  
- Attaches both custom and managed policies to roles  
- Follows the same policy structure used in Stage 1  

Modify only if you need deeper customization.

---

## How to Use

### 1. Configure AWS credentials
Ensure your AWS CLI profile is configured (e.g., `tf-lab`).  
Update `providers.tf` if using a different profile or region.

### 2. Adjust IAM model
Open `locals.tf` and edit:
- Roles  
- External assume targets  
- Default tags  

### 3. Run Terraform
Run the following commands inside `stage-2`:

```
terraform init
terraform plan
terraform apply
```

Terraform will:
- Create IAM roles  
- Create required custom policies  
- Attach policies according to the bindings  

---

## Adding New Functionality

### Add a new IAM role
1. Add the role definition under `iam_roles_model.roles`  
2. Optionally create a new policy set  
3. Add the policy set to `roles_bindings` in `main.tf`  

### Allow a role to assume an external role
Add something like:

```
external_assume = {
  roleA = [
    { account_id = "222222222222", role_name = "roleD" }
  ]
}
```

Then create a policy set granting `sts:AssumeRole` and bind it to the role.

---
