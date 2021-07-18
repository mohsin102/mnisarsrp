//09-15-2020 Created by John Gorrell - Initial code copied from: https://developer.salesforce.com/forums/?id=906F00000009785IAA

  public class UserDocument 
  {
	
	public ContentVersion origContentVersion { get; private set; }
	
	public String friendlyFileType { get; private set; }
	
	public String fileTypeImage { get; private set; }

    private Map<String, String> fileTypeMap = new Map<String, String>{
		'BMP' => 'Image (BMP)',
		'CSV' => 'Comma Separated Values (CSV)',
		'EXCEL' => 'Excel (XLS)',
		'EXCEL_X' => 'Excel 2007 (XLSX)',
		'EXE' => 'Executable (EXE)',
		'GIF' => 'Image (GIF)',
		'JPG' => 'Image (JPG)',
		'MOV' => 'Video (MOV)',
		'MP4' => 'Video (MP4)',
		'PDF' => 'PDF',
		'PNG' => 'Image (PNG)',
		'POWER_POINT' => 'PowerPoint (PPT)',
		'POWER_POINT_X' => 'PowerPoint 2007 (PPTX)',
		'TEXT' => 'Text',
		'UNKNOWN' => 'Unknown',
		'WORD' => 'Word (DOC)',
		'WORD_X' => 'Word 2007 (DOCX)',
		'XML' => 'XML',
		'ZIP' => 'Zip'
	};
       
    private Map<String, String> fileTypeImageMap = new Map<String, String> {
        'BMP' => 'image',
        'CSV' => 'csv',
        'EXCEL' => 'excel',
        'EXCEL_X' => 'excel',
        'EXE' => 'exe',
        'GIF' => 'image',
        'JPG' => 'image',
        'MOV' => 'video',
        'MP4' => 'mp4',
        'PDF' => 'pdf',
        'PNG' => 'image',
        'POWER_POINT' => 'ppt',
        'POWER_POINT_X' => 'ppt',
        'TEXT' => 'txt',
        'UNKNOWN' => 'unknown',
        'WORD' => 'word',
        'WORD_X' => 'word',
        'XML' => 'xml',
        'ZIP' => 'zip'
    };
       
	public UserDocument(ContentVersion cv){
		origContentVersion = cv;
		if(fileTypeMap.get(cv.FileType) != null){
			friendlyFileType = fileTypeMap.get(cv.FileType);
		}
		else{
			friendlyFileType = cv.FileType;
		}
		if(fileTypeImageMap.get(cv.FileType) != null){
			fileTypeImage = fileTypeImageMap.get(cv.FileType);
		}
		else{
			fileTypeImage = 'unknown';
		}
	}

	public UserDocument(){
		origContentVersion = new ContentVersion();
		friendlyFileType = '';
		fileTypeImage = '';
	}
       
		
}