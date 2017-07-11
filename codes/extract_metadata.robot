*** Settings ***
Library    Selenium2Library    run_on_failure=Log Source
Library    Collections
Library    String
Suite Setup    Open Chrome
Library    OperatingSystem
Library    unicodepython2
Suite TearDown    Close Chrome

*** Variables ***
${thich phuoc tien url}    http://phatphapungdung.com/phap-am/giang-su-thich-phuoc-tien/trang-1.html
${video and audio switch id}     jplay_switch_extension
${ppud video server id}    server_video_ppud
${csv file}    metadatatable.csv
${number of pages}    ${EMPTY}
&{Contain PPUD Video And Audio}    Video=${false}    Audio=${false}
${Waiting Time For Page Loading}    ${2}
${global order number}    ${0}

*** Test Cases ***
Get All Metadata From Monk Thich Phuoc Tien
    Get Artist Metadata From All Pages    ${thich phuoc tien url}
  
*** Keywords ***
Get Artist Metadata From All Pages
    [Arguments]    ${url}
    Go To    ${url}

    ${pages}=    Get Number Of Pages

    Set Test Variable    ${number of pages}    ${pages}
    
    # Go To Next Page Until The End
    :FOR    ${page number}    IN RANGE    1    ${number of pages} + 1
    \    Go To Every Album Of Current Page
    \    Go To Next Page

Go To Every Album Of Current Page
    ${current page albums count}=    Get Number Of Albums In Current Page
    ${albums per row}=    Get Number Of Albums In The First Row

    # Extract Metadata From Every Extractable Albums
    :FOR    ${album index}    IN RANGE    1    ${current page albums count} + 1
    \    ${row}=    Evaluate    (${album index} - 1) / ${albums per row} + 1
    \    ${column}=    Evaluate    (${album index} - 1) % ${albums per row} + 1
    \    Click Album Row And Column:    ${row}    ${column}
    \    Extract Media Files Metadata
    \    Go Back

Go To Next Page
    Click Next Button

Get Number Of Albums In Current Page
    ${albums count}=    Get Matching Xpath Count    //div[@id="content"]/div/div[@class="inner"]/*/*/div[@class="item"]
    [Return]    ${albums count}

Get Number Of Albums In The First Row
    ${albums per row}=    Get Matching Xpath Count    //div[@id="content"]/div/div[@class="inner"]/ul/li[1]/div[@class="item"]
    [Return]    ${albums per row}

Click Album Row And Column:
    [Arguments]    ${row}    ${column}
    Click Link    xpath=//div[@id="content"]/div/div[@class="inner"]/*/li[${row}]/div[${column}]/a
    Sleep    ${Waiting Time For Page Loading}    Wait For Album Page Loading

Extract Media Files Metadata
    Check PPUD Video And Audio

    ${album name}=    Get Album Name
    ${genre}=    Get Album Genre
    ${artist}=    Get Album Artist
    ${year}=    Get Album Year
    ${description}=    Get Album Description
    ${image location}=    Get Album Image

    Set Test Variable    ${album name}    ${album name}
    Set Test Variable    ${genre}    ${genre}
    Set Test Variable    ${artist}    ${artist}
    Set Test Variable    ${year}    ${year}
    Set Test Variable    ${description}    ${description}
    Set Test Variable    ${image location}    ${image location}

    If Page Contains Downloadable Video Then Extract Video Files Metadata
    If Page Contains Downloadable Audio Then Extract Audio Files Metadata

If Page Contains Downloadable ${media type} Then Extract ${media type} Files Metadata
    Run Keyword If    &{Contain PPUD Video And Audio}[${media type}]==${true}    Extract ${media type} Files Titles And Downloads

Extract ${media type} Files Titles And Downloads
    Run Keyword    Switch To ${media type} Version    
    ${Playlist Items Count}=    Get Number Of Media Files In Current Playlist

    # Click Every Media (video or audio) Of Current Playlist
    :FOR    ${track number}   IN RANGE    1    ${Playlist Items Count} + 1
    \    Click ${track number}. Media File From Current Playlist
    \    ${download link}=    Run Keyword    Get ${media type} Download Link
    \    ${title}=    Get ${track number}. Media File Title From Current Playlist
    \    ${order number}=    Evaluate    ${global order number} + 1
    \    Set Global Variable    ${global order number}    ${order number}
    \    @{metadata}=    Create List    ${global order number}    ${album name}    ${title}    ${genre}    ${artist}    ${year}    ${description}    ${image location}    ${media type}    ${track number}    ${download link}
    \    Append Row To CSV    ${csv file}    ${metadata}

Switch To Video Version
    ${status}    ${class}=    Run Keyword And Ignore Error     Get Element Attribute    id=jplay_switch_extension@class
    Run Keyword If    "${status}"=="PASS" and "${class}"=="server-mp3"    Click Link    id=jplay_switch_extension
    Sleep    ${Waiting Time For Page Loading}    Wait For Changing Media Type
    Click Link    id=${ppud video server id}
    Sleep    ${Waiting Time For Page Loading}    Wait For Loading Video Playlist

Switch To Audio Version
    ${class}=    Get Element Attribute    id=${video and audio switch id}@class
    Run Keyword If    "${class}"=="server-video"    Click Element    id=${video and audio switch id}
    Sleep    ${Waiting Time For Page Loading}    Wait For Loading Audio Playlist

Get Number Of Media Files In Current Playlist
    ${Playlist Items Count}=    Get Matching Xpath Count    //div[@class="jp-playlist"]/ul/li
    [Return]    ${Playlist Items Count}

Click ${track number}. Media File From Current Playlist
    Click Element    xpath=//div[@class="jp-playlist"]/ul/li[${track number}]/div/a[2]

Get ${track number}. Media File Title From Current Playlist
    ${title}=    Get Text    xpath=//div[@class="jp-playlist"]/ul/li[${track number}]
    [Return]    ${title}

Get Album Name
    ${album name}=    Get Text    css=h1.dt-name
    [Return]    ${album name}

Get Album Genre
    ${genre}=    Get Text    css=ul.list-info li:first-of-type
    ${pre}    ${genre}=    Split String    ${genre}    separator=:    max_split=1
    [Return]    ${genre}

Get Album Artist
    ${artist}=    Get Text    css=ul.list-info li:nth-child(2)
    ${pre}    ${artist}=    Split String    ${artist}    separator=:    max_split=1
    [Return]    ${artist}

Get Album Year
    ${year}=    Get Text    css=ul.list-info li:nth-child(3)
    ${pre}    ${year}=    Split String    ${year}    separator=:    max_split=1
    [Return]    ${year}

Get Album Description
    ${description}=    Get Text    id=wrapcontent
    [Return]    ${description}

Get Album Image
    ${image}=    Get Element Attribute    css=span.img-box>img@src
    [Return]    ${image}

Check PPUD Video And Audio
    If this page contains PPUD videos, then set PPUD video to true. Otherwise set to false
    If this page contains audios, then set Audio to true. Otherwise set to false

If this page contains PPUD videos, then set PPUD video to true. Otherwise set to false
    ${status}    ${video class}=    Run Keyword And Ignore Error    Get Element Attribute    id=${ppud video server id}@class
    Run Keyword If    '${status}'=='PASS'    Set PPUD Video To True
    ...    ELSE    Set PPUD Video To False

If this page contains audios, then set Audio to true. Otherwise set to false
    ${status}    ${audio class}=   Run Keyword And Ignore Error    Get Element Attribute     id=${video and audio switch id}@class
    Run Keyword If    '${status}' == 'PASS'    Set Audio To True
    ...    ELSE    Set Audio To False

Set PPUD Video To True
    Set To Dictionary    ${Contain PPUD Video And Audio}    Video    ${true}

Set PPUD Video To False
    Set To Dictionary    ${Contain PPUD Video And Audio}    Video    ${false}

Set Audio To True
    Set To Dictionary    ${Contain PPUD Video And Audio}    Audio    ${true}

Set Audio To False
    Set To Dictionary    ${Contain PPUD Video And Audio}    Audio    ${false}
    
Get Video Download Link
    ${video download link}=    Get Element Attribute        css=video[id^=jp_video]@src
    [Return]    ${video download link}

Get Number Of Pages
    ${pages}=    Get Element Attribute    css=div#paging_primary span a:last-child@title
    [Return]    ${pages}

Click Next Button
    Click Link    css=div#paging_primary span a:nth-last-child(2)

Get Audio Download Link
    ${audio download link}=    Get Element Attribute        css=audio[id^=jp_audio]@src
    [Return]  	     ${audio download link}

Open Chrome
    Open Browser    about:blank    browser=chrome
    @{headings}=    Create List    Order Number    Album Name    Title    Genre    Artist    Year    Description    Image Location    Media Type    Track Number    Download Link
    Append Row To CSV    ${csv file}    ${headings}
    Maximize Browser Window

Close Chrome
    Close Browser