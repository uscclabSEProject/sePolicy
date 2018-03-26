## 執行 techniqueDeliver.sh，會產生以下動作 
- 創建 linux user NCSISTuser，並設定密碼為 uscc
- 安裝 NCSISTuser module 
- 綁定 linux user 與 SElinux user => ( NCSISTuser, NCSISTuser_u ) 
- 複製資料夾 seProgram 到 /home/NCSISTuser/program/seProgram 
- 安裝 NCSISTprog module
- 安裝 NCSISTprogexec module
- 創建 NCSISTuser 的 Downloads 資料夾
- 創建 firefox 檔案下載的過渡資料夾
- 安裝 NCnoexec module
