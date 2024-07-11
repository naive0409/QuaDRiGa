%% a-b和b-a在一个layout中
clear;
close all;

%% random number generator control
% rng(20240705);
% disp(RandStream.getGlobalStream);

%% constants
position_a = [0; 0; 25]; % alice
position_b = [1; 0; 1.5]; % bob
center_frequency = 3.7e9;
update_rate = 0.01;
no_sc = 64; % subcarrier number
sc_bw = 20e6; % subcarrier bandwidth
track_length = 1.5;
snapshots_to_plot = [10, 20, 30, 40]; % 需要比较的时间快照

%% a->b
%% antenna
a = qd_arrayant('dipole');
a.normalize_gain(1,35); % antenna gain

%% alice track
t_alice = qd_track('linear',0,0); % 不动
t_alice.initial_position = position_a;
t_alice.name = 'trackAlice';

%% bob track
t_bob = qd_track('linear', track_length, 0);
t_bob.movement_profile = [0, track_length * ( 2 / 3 ); 0, track_length]; % 速度1.5m/s
t_bob.initial_position = position_b;
t_bob.name = 'trackBob';

%% alice 2 and bob 2 track
t_alice2 = t_bob;
t_alice2.name = 'trackAlice2';

t_bob2 = t_alice;
t_bob2.name = 'trackBob2';

%% plot distance & time
% dist = t_bob.interpolate('time', 0.1);
% time = (0:numel(dist) - 2)* 0.1;
% plot(time,dist(1:100));
% xlabel('time/s');ylabel('dist/m');grid on;

%% layout init
l = qd_layout;

l.simpar.center_frequency = center_frequency;
l.simpar.show_progress_bars = 0; % 禁用进度条指示器

l.tx_track = [t_alice, t_alice2];
l.rx_track = [t_bob, t_bob2];

l.set_scenario('3GPP_38.901_UMa_NLOS'); % 和论文一样

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate;

% l.visualize(); % 可视化

%% generate channel coeff & frequency response
c = l.get_channels(0); % 计算信道系数
c_initial = c(1,1);
fr_initial = c_initial.fr(no_sc*sc_bw,no_sc); % frequency response : no_rx no_tx no_subcarrier no_snapshot
c_reversed = c(2,2);
fr_reversed = c_reversed.fr(no_sc*sc_bw,no_sc);

%% plot multiple snapshots for comparison
num_snapshots = length(snapshots_to_plot);

figure;
set(gcf,'Position',[100 100 1000 1000]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 提取初始信道系数和反向信道系数
  h_initial = c_initial.coeff(:, :, :, snapshot); % no_rx no_tx no_path no_snapshot
  h_reversed = c_reversed.coeff(:, :, :, snapshot);
  % 创建子图
  subplot(2, 2, i);
  plot(real(h_initial(:)), imag(h_initial(:)), 'o', 'DisplayName', 'Initial(a->b)');
  hold on;
  plot(real(h_reversed(:)), imag(h_reversed(:)), 'o', 'DisplayName', 'Reversed(b->a)');
  title(['Ch Coeff(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  xlabel('Re');
  ylabel('Im');
  legend('show','FontSize',10);
  hold off;
end

figure;
set(gcf,'Position',[1100 100 1000 1000]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 创建子图
  subplot(2, 2, i);
  tmp1 = reshape(fr_initial(:,:,:,i),1,[]);
  tmp2 = reshape(fr_reversed(:,:,:,i),1,[]);
  plot(ifft(tmp1),'o','DisplayName', 'Initial(a->b)');
  hold on;
  plot(ifft(tmp2),'o','DisplayName', 'Reversed(b->a)');
  title(['ifft Ch Frequency Respose(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  xlabel('Re');
  ylabel('Im');
  legend('show','FontSize',10);
  hold off;
end

figure;
set(gcf,'Position',[1100 100 1000 1000]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 创建子图
  subplot(2, 2, i);
  tmp1 = reshape(fr_initial(:,:,:,i),1,[]);
  tmp2 = reshape(fr_reversed(:,:,:,i),1,[]);
  plot(abs(tmp1) ,'-o','DisplayName', 'Initial(a->b)');
  hold on;
  plot(abs(tmp2) ,'-o','DisplayName', 'Reversed(b->a)');
  title(['abs(', num2str(snapshot), ')'],'FontSize',15);
  hold off;
end
