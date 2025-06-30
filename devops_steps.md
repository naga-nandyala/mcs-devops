# DevOps Copilot Studio

1. Start with empty github repo.
2. create an SP
3. grant api permission (dynamics crm/ user impersonation delegate)
4. doing this below (create and application user and grant system administrator role)  -- use and existing env and add this  
5. add secrets and variables to gh (using cicd_setup.sh)

## Initial/brand new build

1. create and environment (production type)
2. (create and application user and grant system administrator role)  -- use and existing env and add this 
3. Start the development on PP.
   1. go to the env
   2. create solution (and publisher???)
   3. create a new agent in PP/MCS
4. use this wf (export-and-branch-solution ) to checking the code to gh.
5. this creates a new branch  (SolutionName-GHActor-UTCtimestamp)
6. raise a PR to see the changes and merge it to main.

## subsequent development of features

1. create a feature branch (feat-01) in gh
2. grant PPA role (see below appendix)
3. create a new env (prod type) with this wf (create-new-env.yml)
4. import the code (solution(s)) into this new env using wf (import-code-into-env.yml)
5. code changes via PP
6. step 4,5,6 in above section to merge changes into feat-01 branch  (PR your checkin branch to feat-01 branch)
7. 
   



## Appendix

### power platform admin role (from Power Shell)

```text
Error: The service principal with id '0c9e2c1c-515e-4274-8ce8-04a0f6c2c778' for application c349cbbe-cd88-4950-9907-74bafca5c1d6 does not have permission to access the path 'https://10.0.8.11:20124/providers/Microsoft.BusinessAppPlatform/locations/unitedstates/environmentLanguages?api-version=2020-08-01' in tenant 183e4064-01e5-41a5-b018-ce616a78c521.
```

```ps1
$appId = "CLIENT_ID_FROM_AZURE_APP"
$tenantId = "TENANT_ID"
Add-PowerAppsAccount -Endpoint prod -TenantID $tenantId 
New-PowerAppManagementApp -ApplicationId $appId
```
