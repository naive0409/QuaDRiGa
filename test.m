clear;

%% random number generator control
rng(20240705);
% disp(RandStream.getGlobalStream);

%% constants
position_a = [0; 0; 25]; % alice
position_b = [1; 0; 1.5]; % bob
center_frequency = 3.7e9;
update_rate = 0.01;

%% a->b
%% antenna
a = qd_arrayant('dipole');
% a = qd_arrayant( 'parabolic', 3, center_frequency, [] , 3);       % Sat. antenna
% a.center_frequency = center_frequency;
% a.copy_element(1,2);                          	% Two identical elements
% a.rotate_pattern(90,'x',2);                   	% Rotate second element by 90 degrees
% a.combine_pattern;                           	% Merge polarized patterns
% a.rotate_pattern(-90,'y');                    	% Point skywards
% [directivity_dBi, gain_dBi] = a.calc_gain();

%% alice track
t_alice = qd_track('linear',0,0);
t_alice.initial_position = position_a;

%% bob track
t_bob = qd_track('linear', 0.75, 0); % 创建新轨迹
t_bob.movement_profile = [0, 0.5; 0, 0.75]; % 1.5m/s
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

l.tx_track = t_alice;
l.rx_track = t_bob;

l.set_scenario('3GPP_38.901_UMa_NLOS'); % 设置场景为非视距NLOS，包含多径效应和阴影衰落

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate; % 100Hz

% l.visualize();title('a->b');

%% generate channel coeff
c = l.get_channels; % 计算信道系数
disp("size of c.coeff:")
disp(size(c.coeff));
% no_rx no_tx no_path no_snapshot
% pow = 10*log10(reshape(sum(abs(c.coeff(:,:,:,:)).^2,3),2,[]));

%% b->a
%% layout init
l = qd_layout;

l.simpar.center_frequency = center_frequency;
l.simpar.show_progress_bars = 0; % 禁用进度条指示器

l.tx_track = t_bob;
l.rx_track = t_alice;

l.set_scenario('3GPP_38.901_UMa_NLOS'); % 设置场景为非视距NLOS，包含多径效应和阴影衰落

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate;

% l.visualize();title('b->a');

%% generate channel coeff
c_reversed = l.get_channels; % 计算新的信道系数

%% plot multiple snapshots for comparison
snapshots_to_plot = [10, 20, 30, 40]; % 需要比较的时间快照
num_snapshots = length(snapshots_to_plot);

figure;
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 提取初始信道系数和反向信道系数
  h_initial = c.coeff(:, :, :, snapshot);
  h_reversed = c_reversed.coeff(:, :, :, snapshot);
  % 创建子图
  subplot(2, 2, i);
  plot(real(h_initial(:)), imag(h_initial(:)), 'o', 'DisplayName', 'Initial(a->b)');
  hold on;
  plot(real(h_reversed(:)), imag(h_reversed(:)), 'x', 'DisplayName', 'Reversed(b->a)');
  title(['Channel Coeff(Snapshot ', num2str(snapshot), ')']);
  xlabel('Re');
  ylabel('Im');
  legend('show');
  hold off;
end
