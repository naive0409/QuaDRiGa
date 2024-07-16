%% a-b和b-a分成两个layout
clear;
close all;

%% random number generator control
% rng(20240705);
% disp(RandStream.getGlobalStream);

%% constants
position_a = [0; 0; 5]; % alice
position_b = [1; 0; 1.5]; % bob
center_frequency = 3.7e9;
update_rate = 0.01;
no_sc = 64; % subcarrier number
sc_bw = 30e3; % subcarrier bandwidth
track_length = 1;
snapshots_to_plot = [10, 11, 12, 13];
% snapshots_to_plot = [10, 20, 30, 40]; % 需要比较的时间快照

%% a->b
%% antenna
a = qd_arrayant('dipole');
a.normalize_gain(1,35); % antenna gain

%% alice track
t_alice = qd_track('linear', 1e-3, 0);
t_alice.set_speed(1e-3);
t_alice.initial_position = position_a;

%% bob track
t_bob = qd_track('linear', track_length, 0);
t_bob.set_speed(track_length);
t_bob.initial_position = position_b;

%% plot distance & time
% dist = t_bob.interpolate('time', 0.1);
% time = (0:numel(dist) - 2)* 0.1;
% plot(time,dist(1:100));
% xlabel('time/s');ylabel('dist/m');grid on;

%% layout init
l = qd_layout;

l.simpar.center_frequency = center_frequency;
l.simpar.show_progress_bars = 0; % 禁用进度条指示器
% l.simpar.use_random_initial_phase = 0;
% l.simpar.use_absolute_delays = 1;

l.tx_track = t_alice;
l.rx_track = t_bob;

l.set_scenario('3GPP_38.901_UMa_NLOS'); % 和论文一样

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate;

% l.visualize();title('a->b'); % 可视化

%% generate channel coeff & biulder & frequency response
[c_initial, builder_initial]= l.get_channels(); % 计算信道系数
c_initial.individual_delays = 0;
fr_initial = c_initial.fr(no_sc*sc_bw,no_sc); % frequency response : no_rx no_tx no_subcarrier no_snapshot
% disp("size of c_initial.coeff:")
% disp(size(c_initial.coeff));
% pow = 10*log10(reshape(sum(abs(c_initial.coeff(:,:,:,:)).^2,3),2,[]));

%% b->a
%% layout init
l = qd_layout;

l.simpar.center_frequency = center_frequency;
l.simpar.show_progress_bars = 0; % 禁用进度条指示器
l.simpar.use_random_initial_phase = 0;
l.simpar.use_absolute_delays = 1;

l.tx_track = t_bob;
l.rx_track = t_alice;

l.set_scenario('3GPP_38.901_UMa_NLOS');

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate;

l.h_qd_builder_init = builder_initial;
l.track_checksum = checksum( l.rx_track ) + checksum( l.tx_track ) + checksum( l.simpar );
l.use_channel_interpolation = true;

% l.visualize();title('b->a');

%% generate channel coeff & frequency response
c_reversed = l.get_channels; % 计算新的信道系数
c_reversed.individual_delays = 0;
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
  plot(reshape(fr_initial(:,:,:,i),1,[]),'o','DisplayName', 'Initial(a->b)');
  hold on;
  plot(reshape(fr_reversed(:,:,:,i),1,[]),'o','DisplayName', 'Reversed(b->a)');
  title(['Ch Frequency Respose(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  xlabel('Re');
  ylabel('Im');
  legend('show','FontSize',10);
  hold off;
end

figure;
set(gcf,'Position',[1100 100 1000 1000]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  subplot(2, 2, i);
  plot(abs(reshape(fr_initial(:,:,:,i),1,[])),'-o','DisplayName', 'Initial(a->b)');
  hold on;
  plot(abs(reshape(fr_reversed(:,:,:,i),1,[])),'-o','DisplayName', 'Reversed(b->a)');
  title(['abs Ch Frequency Respose(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  legend('show','FontSize',10);
  hold off;
end
