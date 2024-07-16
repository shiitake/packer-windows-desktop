@echo off
SET sourceFile=.\answer_files\11_hyperv\Autounattend.Base.xml
SET destFile=.\answer_files\11_hyperv\Autounattend.xml

IF NOT EXIST %destFile% (
  echo The file %destFile% does not exist, creating a copy from %sourceFile%
  COPY %sourceFile% %destFile%
  SET userName=vagrant
) ELSE (
  echo The file %destFile% already exists.
  SET /P userName=Please enter a username:
)

packer init windows_11.pkr.hcl
packer build --force ^
  --only=%1-iso.%1 ^
  -var "username=%userName%" ^
  -var "password=%userName%" ^
  windows_11.pkr.hcl
