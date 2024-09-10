no_sc = 30; % subcarrier number
sc_bw = 30e3; % subcarrier bandwidth
snapshots_to_plot = [1, 2, 3];
num_snapshots = length(snapshots_to_plot);
file_nums = 10000; % 文件总数
dir = sprintf('./');

for cnt = 1:file_nums
    if mod(cnt,1000) == 0
        fprintf('%d\n', cnt);
    end

    filename = sprintf('./quadriga_channel/c_%d.mat', cnt);
    load(filename, 'c_initial', 'c_reversed');

    fr_initial = c_initial.fr(no_sc*sc_bw,no_sc);
    fr_initial = squeeze(fr_initial);
    cir_initial = ifft(fr_initial);% ifft
    
    fr_reversed = c_reversed.fr(no_sc*sc_bw,no_sc);
    fr_reversed = squeeze(fr_reversed);
    cir_reversed = ifft(fr_reversed);
    
    save([dir, 'quadriga_CIR/CIR_', num2str(cnt),'.mat'], "cir_initial","cir_reversed");
end

return


figure;
set(gcf,'Position',[300 100 600 600]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 创建子图
  subplot(2, 2, i);
%   plot(reshape(fr_initial(:,:,:,snapshot),1,[]),'o','DisplayName', 'Initial(a->b)');
%   plot(fr_initial(:,snapshot),'o','DisplayName', 'Initial(a->b)');
  plot(cir_initial(:,snapshot),'o','DisplayName', 'Initial(a->b)');
  hold on;
%   plot(reshape(fr_reversed(:,:,:,snapshot),1,[]),'o','DisplayName', 'Reversed(b->a)');
%   plot(fr_reversed(:,snapshot),'o','DisplayName', 'Reversed(b->a)');  
  plot(cir_reversed(:,snapshot),'o','DisplayName', 'Reversed(b->a)');
  title(['Ch Frequency Respose(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  xlabel('Re');
  ylabel('Im');
  legend('show','FontSize',10);
  hold off;
end