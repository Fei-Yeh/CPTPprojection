dmax = 4;
Npowmin = 3;
Npowmax = 6;
ensemble_size = 1000;
for d = 4:4
    A = PM_minimal(d);
    

    for l=1:ensemble_size
            fprintf(char(10));
            fprintf('%d ', l); 
            % generate random ground truth
    %         choi_ground     = rand(d*d,d*d)-rand(d*d,d*d)+1.0j*rand(d*d,d*d)-1.0j*rand(d*d,d*d);
    %         choi_ground_vec = reshape(choi_ground,[],1);
    %         choi_ground_vec = CPTP_project(choi_ground_vec, MdagM, Mdagb);
    %         choi_ground     = reshape(choi_ground_vec,[],d*d);

    % %         choi_ground     = randomCPTP(d,1); % kraus rank 1, i.e unitary map.
%             choi_ground     = randomCPTP(d,d*d); % kraus rank is full.
    %         choi_ground_vec = reshape(choi_ground,[],1);


            choi_ground     = randomCPTP_quasi_pure(d,0.9);
            choi_ground_vec = reshape(choi_ground,[],1);

            p               = real(A*choi_ground_vec);
%             p               = p/sum(p);
%             p               = p*d*d;

    %         for Npow=[1,2,3,4,5,6,7,8,Inf] % above Npow=9 the memory requirements are huge for simulating multinomial noise
            for Npow=Npowmin:Npowmax                            
                N = 10^Npow;

                if isinf(N)
%                     p           = reshape(p,[],1);
                    n           = p;
    %                 n           = n./sum(n);
                else
                    pmat           = reshape(p,[],2*d*d); % need an object with n_measurement_outcomes columns
                    pmat           = pmat./sum(pmat,2); % does not look necessary but it is useful to avoid near misses where probs sum to 1-e.
%                     for m=1:d*d % loop over input states
%                         pmat(m,:) = pmat(m,:)./sum(pmat(m,:));
%                     end
                    nmat           = mnrnd(N,pmat);
%                     for m=1:d*d
%                         n(m,:)   = n(m,:)./sum(n(m,:)); % proper normalisation so that click counts are now frequencies
%                     end
                    nmat        = nmat./sum(nmat,2); % proper normalisation so that sum(nmat,2)=1
                    n           = reshape(nmat,[],1);
               

%                     n           = n./sum(n);
    %                 sum(n)


    % 
%                     for i=1:2*d*d:(2*d*d*d*d-d*d) % for each preparation take the click distribution
%                         n(i:i+2*d*d-1) = n(i:i+2*d*d-1)/sum(n(i:i+2*d*d-1)); % normalise to 'frequencies' 
% %                         TODO make sure that this is simply dividing whole
%                         % likelihood by a constant.
%                     end
                end
                
%                 choi_li = choi_ground_vec;
                choi_li = LinInversion(A,n);
%                 choi_li = gdapB(A,n);
%                 distance_to_CP(Npow,l) = norm(reshape(choi_li,[],d*d)-reshape(PSD_project(choi_li),[],d*d),'fro');
                choi_li_matrix = reshape(choi_li,[],d*d);
                choi_li_matrix = (choi_li_matrix'+choi_li_matrix)/2;
%                 eig(choi_li_matrix)
                smallest_ev(d,Npow,l)           = min(eig(choi_li_matrix));
                frob_dist_to_TP(d,Npow,l)       = norm(partial_trace(choi_li_matrix)-eye(d),'fro');
%                 smallest_evPROJECTED(d,Npow,l)  = min(eig(reshape(PSD_project(choi_li),[],d*d)));
    %         n               = p; % noiseless scenario            
            end
    end
end
figure('Position',[1 0 800 250]);
hold on;
m  = mean(smallest_ev,3);
sd = std(smallest_ev,0,3);
for d=2:dmax
    errorbar(Npowmin:Npowmax,m(d,Npowmin:Npowmax),sd(d,Npowmin:Npowmax),'LineWidth',2)
end
xlim([Npowmin-0.5,Npowmax+0.5])
ylabel('smallest eigenvalue')
xlabel('log(N)')
xticks(Npowmin:Npowmax)
set(gca,'YScale','log');
figure('Position',[1 0 800 250]);

hold on;
for Npow=Npowmin:Npowmax
%     subplot(1,2,1)
%     hold on;
%     histogram(real(distance_to_CP(Npow,:)))
%     subplot(1,2,2)
    subplot(1,2,1)
    hold on;box on;
%     title('Smallest eigenvalue (Full rank ensemble)')
%     title('Smallest eigenvalue')
    xlabel('smallest eigenvalue')
    ylabel('number')
    h = histogram(real(smallest_ev(d,Npow,:)),'DisplayName',num2str(10^Npow));
% %     hp= histogram(real(smallest_evPROJECTED(d,Npow,:)));
    h.EdgeColor = 'none';
    h.FaceAlpha = 1;
    h.EdgeAlpha = 1;
    subplot(1,2,2)
    xlabel('distance to TP')
    ylabel('number')
    hold on;
%     title('Frobenius distance to TP (Full rank ensemble)')
%     title('Frobenius distance to TP ')
    hold on; box on;
    h = histogram(real(frob_dist_to_TP(d,Npow,:)),'DisplayName',num2str(10^Npow));
% %     hp= histogram(real(smallest_evPROJECTED(d,Npow,:)));
    h.EdgeColor = 'none';
    h.FaceAlpha = 1;
    h.EdgeAlpha = 1;
   
%     hp.EdgeColor = 'none';
end
lgd = legend('show');
title(lgd,'N')
% subplot(1,2,1)
% title('distance to CP')
% legend('Npow = 2','Npow = 3')
% subplot(1,2,2)
% legend('Npow = 2','Npow = 3')
% title(['Linear Inversion d = ',num2str(dmax)])
yl = ylim;
plot([0,0],yl,'-k')
% clear smallest_ev
% clear frob_dist_to_TP
% for d = 4:4
%     A = PM_minimal(d);
% 
%     for l=1:ensemble_size
%             fprintf(char(10));
%             fprintf('%d ', l); 
%             % generate random ground truth
%     %         choi_ground     = rand(d*d,d*d)-rand(d*d,d*d)+1.0j*rand(d*d,d*d)-1.0j*rand(d*d,d*d);
%     %         choi_ground_vec = reshape(choi_ground,[],1);
%     %         choi_ground_vec = CPTP_project(choi_ground_vec, MdagM, Mdagb);
%     %         choi_ground     = reshape(choi_ground_vec,[],d*d);
% 
%     % %         choi_ground     = randomCPTP(d,1); % kraus rank 1, i.e unitary map.
% %             choi_ground     = randomCPTP(d,d*d); % kraus rank is full.
%     %         choi_ground_vec = reshape(choi_ground,[],1);
% 
% 
%             choi_ground     = randomCPTP_quasi_pure(d,0.9);
%             choi_ground_vec = reshape(choi_ground,[],1);
% 
%             p               = real(A*choi_ground_vec);
% %             p               = p/sum(p);
% %             p               = p*d*d;
% 
%     %         for Npow=[1,2,3,4,5,6,7,8,Inf] % above Npow=9 the memory requirements are huge for simulating multinomial noise
%             for Npow=Npowmin:Npowmax                            
%                 N = 10^Npow;
% 
%                 if isinf(N)
% %                     p           = reshape(p,[],1);
%                     n           = p;
%     %                 n           = n./sum(n);
%                 else
%                     pmat           = reshape(p,[],2*d*d); % need an object with n_measurement_outcomes columns
% %                     for m=1:d*d % loop over input states
% %                         pmat(m,:) = pmat(m,:)./sum(pmat(m,:));
% %                     end
%                     nmat           = mnrnd(N,pmat);
% %                     for m=1:d*d
% %                         n(m,:)   = n(m,:)./sum(n(m,:)); % proper normalisation so that click counts are now frequencies
% %                     end
%                     nmat        = nmat./sum(nmat,2); % proper normalisation so that sum(nmat,2)=1
%                     n           = reshape(nmat,[],1);
%                 end
%     % 
% 
%                 choi_li = LinInversion(A,n);
% %                 choi_li = gdapB(A,n);
% %                 distance_to_CP(Npow,l) = norm(reshape(choi_li,[],d*d)-reshape(PSD_project(choi_li),[],d*d),'fro');
%                 choi_li_matrix = reshape(choi_li,[],d*d);
%                 choi_li_matrix = (choi_li_matrix'+choi_li_matrix)/2;
% %                 eig(choi_li_matrix)
%                 smallest_ev(d,Npow,l)           = min(eig(choi_li_matrix));
%                 frob_dist_to_TP(d,Npow,l)       = norm(partial_trace(choi_li_matrix)-eye(d),'fro');
% %                 smallest_evPROJECTED(d,Npow,l)  = min(eig(reshape(PSD_project(choi_li),[],d*d)));
%     %         n               = p; % noiseless scenario            
%             end
%     end
% end
% 
% for Npow=Npowmin:Npowmax
% %     subplot(1,2,1)
% %     hold on;
% %     histogram(real(distance_to_CP(Npow,:)))
% %     subplot(1,2,2)
%     subplot(2,2,3)
%     title('Smallest eigenvalue (Quasi-pure ensemble)')
%     xlabel('smallest eigenvalue')
%     ylabel('number')
%     hold on;
%     h = histogram(real(smallest_ev(d,Npow,:)),'DisplayName',num2str(10^Npow));
% % %     hp= histogram(real(smallest_evPROJECTED(d,Npow,:)));
%     h.EdgeColor = 'none';
%     h.FaceAlpha = 1;
%     h.EdgeAlpha = 1;
%     subplot(2,2,4)
%     xlabel('distance')
%     ylabel('number')
%     hold on;
%     title('Frobenius distance to TP (Quasi-pure ensemble)')
%     h = histogram(real(frob_dist_to_TP(d,Npow,:)),'DisplayName',num2str(10^Npow));
% % %     hp= histogram(real(smallest_evPROJECTED(d,Npow,:)));
%     h.EdgeColor = 'none';
%     h.FaceAlpha = 1;
%     h.EdgeAlpha = 1;
%    
%    
% %     hp.EdgeColor = 'none';
% end
% lgd = legend('show');
% title(lgd,'N')
% 
% 
% % subplot(1,2,1)
% 
% % legend('Npow = 2','Npow = 3')
% % subplot(1,2,2)
% % legend('Npow = 2','Npow = 3')
% % title(['Linear Inversion d = ',num2str(dmax)])
% yl = ylim;
% plot([0,0],yl,'-k')


saveas(gcf,['./plots/d',num2str(d),'smallestEV.png'])
saveas(gcf,['./plots/d',num2str(d),'smallestEV.eps'],'epsc')
set(gcf,'paperpositionmode','auto')
print(gcf,'-depsc2','-loose',['./plots/ALTd',num2str(d),'smallestEV.eps'])
    