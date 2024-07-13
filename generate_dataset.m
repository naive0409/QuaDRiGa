% 定义输入矩阵
matrix = [1+1i, 2+2i; 
    3+3i, 4+4i; 
    5+5i, 6+6i];
tmp_initial = reshape(fr_initial,no_sc,[]);
tmp_initial(:,end) = [];
tmp_reversed = reshape(fr_initial,no_sc,[]);
tmp_reversed(:,end) = [];

disp(size(tmp_initial));
disp(size(tmp_reversed));

% 调用函数，将结果分别写入 'amplitude.txt' 和 'phase.txt'
writeAmplitudeAndPhase(tmp_initial, 'result\amplitude_initial.txt', 'result\phase_initial.txt');
writeAmplitudeAndPhase(tmp_reversed, 'result\amplitude_reversed.txt', 'result\phase_reversed.txt');

disp('Done.')
