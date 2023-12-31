      *IDENTIFICATION DIVISION programın kimlik bilgilerinin
      *belirtildiği bölümdür. Bu bölümde programın adı ve programı 
      *oluşturan kişi belirtilmiştir.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PBHWORK2.
       AUTHOR. AHMET MELİH ÇALMAZ.
      *ENVIRONMENT DIVISION programın çalıştığı ortamı ve 
      *kullanılacak dosyaları içerir.
       ENVIRONMENT DIVISION.
      *INPUT-OUTPUT programda kullanılacak olan girdi ve çıktı dosyaları
      *tanımlar. 
       INPUT-OUTPUT SECTION.
      *FILE-CONTROL programın "PRT-LINE" ve "DATE-REC" dosyalarını
      *kullanacağını ve bu dosyaların fiziksel bağlantılarını ve 
      *durumlarını belirlediğini göstermektedir.
      *Bu tanımlamalar, programın dosya işlemlerini yapabilmesi için
      *gerekli olan dosya bağlantılarını ve durum kontrollerini sağlar.
       FILE-CONTROL.
           SELECT PRINT-LINE ASSIGN TO PRTLINE
                             STATUS ST-PRINT-LINE. 
           SELECT DATE-REC   ASSIGN TO DATEREC
                             STATUS ST-DATE-REC. 
      *DATA DIVISION programda kullanılacak tüm verilerin yönetimi 
      *kısmıdır.
       DATA DIVISION.
       FILE SECTION.
       FD  PRINT-LINE RECORDING MODE F.
      *"PRT-LINE" adlı dosyayı tanımlar ve F (fixed) modda çalıştırır.
      *yani girilen veri boyutlarının tam boyut olduğunu belirtir.
         01  PRINT-REC.
           03 REC-ID-O          PIC X(4).
           03 REC-NAME-O        PIC X(15).
           03 REC-SRNAME-O      PIC X(15).
           03 REC-DATE-O        PIC 9(08).
           03 REC-NDATE-O       PIC 9(08).
           03 REC-LDAY-O        PIC 9(08).
       FD  DATE-REC RECORDING MODE F.
      *"DATE-REC" adlı dosyayı tanımlar ve F (fixed) modda çalıştırır.
      *yani girilen veri boyutlarının tam boyut olduğunu belirtir.
         01  DATEIN.
           03 REC-ID            PIC X(4).
           03 REC-NAME          PIC X(15).
           03 REC-SRNAME        PIC X(15).
           03 REC-DATE          PIC 9(08).
           03 REC-NDATE         PIC 9(08).

       WORKING-STORAGE SECTION.
      *WORKING-STORAGE SECTION programın çalışması sırasında işlem 
      *yapmak için kullanılan değişkenleri ve veri alanlarını tanımlar.
         01  WS-WORK-AREA. 
           03 ST-DATE-REC        PIC 9(2).
           88 DATE-REC-EOF                   VALUE 10.
           03 ST-PRINT-LINE      PIC 9(2).
         01 DATECALC.
           05 REC-DATE-INT      PIC 9(08).
           05 REC-NDATE-INT     PIC 9(08).
           05 REC-LDAY          PIC 9(08).

      *--------------------     
       PROCEDURE DIVISION.
      *Maini oluşturduk burada yazılı olan sırada paragrafları takip
      *edip programı tamamlayacağız.
       0000-MAIN.
           PERFORM H100-OPEN-FILES
           PERFORM H200-READ-NEXT-RECORD UNTIL DATE-REC-EOF
           PERFORM H999-PROGRAM-EXIT.
       0000-END. EXIT.
      *INPUT ve OUTPUT dosyalarını açtık ve output dosyasının ilk
      *satırını okuduk. 
       H100-OPEN-FILES.
           OPEN INPUT  DATE-REC.
           OPEN OUTPUT PRINT-LINE.
           IF (ST-DATE-REC NOT = 0) AND (ST-DATE-REC NOT = 97)
           DISPLAY 'UNABLE TO OPEN INPFILE: ' ST-DATE-REC 
           MOVE ST-DATE-REC TO RETURN-CODE
           PERFORM H999-PROGRAM-EXIT
           END-IF.
           IF (ST-PRINT-LINE NOT = 0) AND (ST-PRINT-LINE NOT = 97)
           DISPLAY 'UNABLE TO OPEN OUTFILE: ' ST-PRINT-LINE 
           MOVE ST-PRINT-LINE TO RETURN-CODE
           PERFORM H999-PROGRAM-EXIT
           END-IF.
           READ DATE-REC.
           IF (ST-DATE-REC NOT = 0) AND (ST-DATE-REC NOT = 97)
           DISPLAY 'UNABLE TO READ INPFILE: ' ST-DATE-REC 
           MOVE ST-DATE-REC TO RETURN-CODE
           PERFORM H999-PROGRAM-EXIT
           END-IF.
       H100-END. EXIT.
      *Dosyalar açılırken bir problemle karşılaşıldı mı diye kontrol
      *ettik eğer ki karşılaşılmışsa hata mesajı yazdırıp programı 
      *sonlandırdık. 
       H200-READ-NEXT-RECORD.
               PERFORM CALC-RECORD
               READ DATE-REC.
       H200-END. EXIT.
      *INPUT dosyasından edindiğimiz bilgileri OUTPUT dosyamıza aktarmak
      *için OUTPUT dosyası için oluştuduğumuz değişkenlere bu bilgileri
      *yerleştiriyoruz ve yapılması gereken matematiksel işlemleri
      *yapıyoruz.
       CALC-RECORD.
           COMPUTE REC-DATE-INT = FUNCTION INTEGER-OF-DATE(REC-DATE)
           COMPUTE REC-NDATE-INT = FUNCTION INTEGER-OF-DATE(REC-NDATE)
           COMPUTE REC-LDAY = REC-NDATE-INT - REC-DATE-INT
           PERFORM WRITE-RECORD.
       CALC-END. EXIT.
           
       WRITE-RECORD.
           MOVE REC-ID       TO  REC-ID-O.
           MOVE REC-NAME     TO  REC-NAME-O.
           MOVE REC-SRNAME   TO  REC-SRNAME-O.
           MOVE REC-DATE     TO  REC-DATE-O.
           MOVE REC-NDATE    TO  REC-NDATE-O.
           MOVE REC-LDAY     TO  REC-LDAY-O.
           WRITE PRINT-REC.
       WRITE-END. EXIT.
      *INPUT ve OUTPUT dosyalarını kapatıp programı sonlandırıyoruz.
       H999-PROGRAM-EXIT.
           CLOSE DATE-REC.
           CLOSE PRINT-LINE.
           GOBACK.
           
      *