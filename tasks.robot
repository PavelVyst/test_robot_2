*** Settings ***
Documentation       Template robot main suite.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
...
...               Only the robot is allowed to get the orders file. You may not save the file manually on your computer.
...               The robot should save each order HTML receipt as a PDF file.
        ...       The robot should save a screenshot of each of the ordered robots.
        ...       The robot should embed the screenshot of the robot to the PDF receipt.
        ...       The robot should create a ZIP archive of the PDF receipts (one zip archive that contains all the PDF files). Store the archive in the output directory.
        ...       The robot should complete all the orders even when there are technical failures with the robot order website.
        ...       The robot should be available in public GitHub repository.
        ...       It should be possible to get the robot from the public GitHub repository and run it without manual setup.

Library    RPA.Browser.Selenium    
...    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.PDF
Library    RPA.Tables
Library    RPA.RobotLogListener
Library    RPA.Archive

*** Tasks ***

Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal
    
    Download the Excel file
    Get orders
    Create a ZIP file of receipt PDF files

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
Download the Excel file
    Download    
    ...    https://robotsparebinindustries.com/orders.csv    
    ...    overwrite=True


    
Get orders
    ${orders} =    Read table from CSV 
    ...    orders.csv    
    ...    header=True

    
    FOR    ${row}    IN     @{orders}


 
        Fill the form    ${row}
  
        Embed the robot screenshot to the receipt PDF file    ${row}
    END
Fill the form

    [Arguments]    ${row}
    Select From List By Value    css:#head    ${row}[Head]
    IF    ${row}[Body] == 1
        Click Element    css:#id-body-1
    ELSE IF    ${row}[Body] == 2
            Click Element    css:#id-body-2
    ELSE IF    ${row}[Body] == 3
            Click Element    css:#id-body-3
    ELSE IF    ${row}[Body] == 4
            Click Element    css:#id-body-4
    ELSE IF    ${row}[Body] == 5
            Click Element    css:#id-body-5
    ELSE 
            Click Element    css:#id-body-6
    END

    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]
    Input Text    css:#address    ${row}[Address]    clear=True
    Click Button    css:#preview
    Screenshot    
    ...    css:#robot-preview-image    
    ...    ${OUTPUT_DIR}${/}output/png/${row}[Order number].png
    ${error}=    Is Element Visible    css:#order-another    
    WHILE    ${error}!=${True}
        
        Click Button
        ...    css:#order
        ${error}=    Is Element Visible    css:#order-another 
    END
    Store the receipt as a PDF file   ${row} 
    Wait And Click Button    css:#order-another
    Close the annoying modal

Close the annoying modal
    Click Button    
    ...    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

 
Store the receipt as a PDF file
    [Arguments]    
    ...    ${row}   
    Wait Until Element Is Visible    css:#order-completion
    ${receipt} =    Get Element Attribute    css:#order-completion    outerHTML
    Html To Pdf    
    ...    ${receipt}    
    ...    output_path=${OUTPUT_DIR}${/}output/pdf/${/}${row}[Order number].pdf
Embed the robot screenshot to the receipt PDF file
    [Arguments]    
    ...    ${row}


    Open PDF    ${OUTPUT_DIR}${/}output/pdf/${/}${row}[Order number].pdf
    ${files}=    Create List
    ...      ${OUTPUT_DIR}${/}output/png/${row}[Order number].png
    ...      ${OUTPUT_DIR}${/}output/pdf${/}${row}[Order number].pdf


    Add files to pdf    ${files}       ${OUTPUT_DIR}${/}output/pdf/${/}${row}[Order number].pdf
    Close Pdf
Create a ZIP file of receipt PDF files
    Archive Folder With Zip   ${OUTPUT_DIR}${/}output/pdf     receipts.zip      

        
    Close Browser