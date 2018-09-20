function my_closereq(src,evnt)
% User-defined close request function 
% to display a question dialog box 
   selection = questdlg('Save the data before closing This Figure?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         [FileName,PathName,FilterIndex] = uiputfile({'*.fig', 'Matlab Figure (*.fig)';...
             '*.png', 'Portable Network Graphics(*.png)';...
             '*.bmp', 'Windows bitmap (*.bmp)'}, 'Save figure As...'); 
         saveas(gcf, [PathName, FileName]); 
         delete(gcf)
      case 'No'
          delete(gcf)
      return 
   end
end