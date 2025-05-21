# Customer ZIP Audit

| Path                                | What is it?                                   | Action                                                       | Touches subscriptions? |
| ----------------------------------- | --------------------------------------------- | ------------------------------------------------------------ | ---------------------- |
| legacy/artifacts/apis/              | Folder of OpenAPI specs exported by extractor | **Keep** (will copy into `/apis`)                    | No                     |
| legacy/artifacts/diagnostics/       | ARM diagnostics settings                      | Keep                                                         | No                     |
| legacy/artifacts/policy.xml         | Global policy XML fragment                    | Refactor (split into fragments)                              | No                     |
| legacy/artifacts/products/          | Product definitions (JSON)                    | **Refactor** (ensure deploySubscriptions flag = false) | No*                    |
| legacy/configuration.extractor.yaml | Extractor config (Dev)                        | Keep                                                         | No                     |
| legacy/configuration.prod.yaml      | Extractor config (Prod)                       | Keep                                                         | No                     |
| legacy/tools/pipelines/             | Old Azure DevOps YAML templates               | **Refactor** (convert to GitHub Actions)               | No*                    |
| legacy/README.md                    | Original hackathon read-me                    | Drop (replace w/new docs)                                    | n/a                    |
