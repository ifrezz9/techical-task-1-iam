# IAM Baseline — Quick Guide

This README explains **what to edit and where** when working with the Stage‑1 IAM baseline Terraform project.

---

## 1. locals.tf — IAM Model Configuration

This is the **main configuration file**.  
Here you define:
- IAM groups  
- IAM users  
- Managed policy sets  
- Custom policy sets  
- Bindings (which policy sets apply to which group)

### You edit this file when you want to:
- Add or remove groups  
- Add or remove users  
- Add new policies  
- Change which group gets which policies  

### You never place Terraform resources here — only data structures.

---

## 2. main.tf — Module Wiring

This file only:
- calls modules  
- passes data from locals.tf into those modules  

### You edit this file when:
- module name changes  
- you add more modules in future stages  

Normally you do **not** touch this file.

---

## 3. modules/iam-groups-users

Handles:
- creating IAM groups  
- creating IAM users  
- membership in groups  
- tagging users  

### You edit only if:
- you want MFA enforcement  
- you want to add password policy  
- you want custom naming conventions  

Otherwise do not modify.

---

## 4. modules/iam-policies-bindings

Handles:
- creation of custom policies  
- attachment of managed policies  
- binding policy sets to groups  
- optional binding policy sets to users  

### You edit only if:
- you want different logic for policy naming  
- you want additional policy attachment rules  

Normally leave as-is.

---

## 5. How to Add a New Group

Steps:
1. Open locals.tf  
2. In `iam_model.groups` add a new group with user list  
3. In `bindings.groups` assign policy sets  
4. Run `terraform plan`  

---

## 6. How to Add a New User

Steps:
1. Open locals.tf  
2. Add user to the proper group  
3. Run `terraform plan`  

---

## 7. How to Add a Managed Policy Set

Steps:
1. Open locals.tf  
2. Under `iam_model.policies.managed` add a new named list of ARNs  
3. Bind it in `bindings.groups`  

---

## 8. How to Add a Custom Policy Set

Steps:
1. Open locals.tf  
2. Under `iam_model.policies.custom` add a new named set containing JSON policy  
3. Bind it in `bindings.groups` or `bindings.users`  
