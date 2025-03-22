For unlock, run this trice:
```
kubectl exec -ti -n vault-system vault-0 -- sh
/ # VAULT_ADDR=http://127.0.0.1:8200 vault operator unseal
```
Put in the codes you got from vault init
