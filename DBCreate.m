classdef DBCreate
    %DBCREATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % File paths
        pfasta
        nfasta
        
        % Nucleotides compositions vectors
        dnucs
        tnucs
        
        % Sequences with Dinucleotides indexes
        dipos
        dineg

        % Sequences with Trinucleotides indexes
        tripos
        trineg

        % Reference to convert indexes to values
        diconv
        triconv
        
    end
    
    methods
        
        function obj = DBCreate(pos_fasta, neg_fasta)
            if nargin ~= 0
                obj.pfasta = pos_fasta;
                obj.nfasta = neg_fasta;
            else
                obj.pfasta = '';
                obj.nfasta = '';
            end
            
            obj = obj.set_nucs();
%             obj = obj.get_sequences();
        end
        
        function obj = set_nucs(obj)
            keys = {'GGG','GGA','GGC','GGT','GAG','GAA','GAC','GAT','GCG','GCA','GCC','GCT','GTG','GTA','GTC','GTT','AGG','AGA','AGC','AGT','AAG','AAA','AAC','AAT','ACG','ACA','ACC','ACT','ATG','ATA','ATC','ATT','CGG','CGA','CGC','CGT','CAG','CAA','CAC','CAT','CCG','CCA','CCC','CCT','CTG','CTA','CTC','CTT','TGG','TGA','TGC','TGT','TAG','TAA','TAC','TAT','TCG','TCA','TCC','TCT','TTG','TTA','TTC','TTT'};
            values = 1:length(keys);
            obj.tnucs = containers.Map(keys, values);
            
            keys = {'GG','GA','GC','GT','AG','AA','AC','AT','CG','CA','CC','CT','TG','TA','TC','TT'};
            values = 1:length(keys);
            obj.dnucs = containers.Map(keys, values);
        end
        
        function obj = setRefTables(obj, dipath, tripath)
            obj.diconv = csvread(dipath);
            obj.triconv = csvread(tripath);
        end
        
        function obj = get_sequences(obj)
            % Open fasta files
            fp = fastaread(obj.pfasta);
            fn = fastaread(obj.nfasta);
            
            [obj.dipos, obj.tripos] = obj.extract_values(fp);
            [obj.dineg, obj.trineg] = obj.extract_values(fn);
            
        end
        
        function [di, tri] = extract_values(obj, fastaobj)
            
            % Get number of rows and columns
            rows = length(fastaobj);
            cols = length(fastaobj(1,:).Sequence);
            
            % Preallocate matrix for Di and Tri
            di = zeros(rows, cols-1);
            tri = zeros(rows, cols-2);
            
            
            % Process Dinucleotides
            parfor i=1:rows
                disp(i);
                for j = 1:cols-1
                    seq = fastaobj(i,:).Sequence(1, j:j+1);
                    di(i,j) = obj.dnucs(seq);
                end
            end
            di = uint8(di);
            
            
            % Process Trinucleotides
            parfor i=1:rows
                disp(i);
                for j = 1:cols-2
                    seq = fastaobj(i,:).Sequence(1, j:j+2);
                    tri(i,j) = obj.tnucs(seq);
                end
            end
            tri = uint8(tri);
            
        end
        
        function obj = write_nuc_compositions(obj)
            csvwrite( fullfile('.', 'convDiPos.csv'), obj.dipos );
            csvwrite( fullfile('.', 'convDiNeg.csv'), obj.dineg );
            
            csvwrite( fullfile('.', 'convTriPos.csv'), obj.tripos );
            csvwrite( fullfile('.', 'convTriNeg.csv'), obj.trineg );
        end
        
        function names = getDatasetsNames(obj)
            dbs = dir('data');
            dbs = dbs(3:end);
            
            names = {};
            for i=1:size(dbs,1)
                names{i} = dbs(i,:).name;
            end
        end
        
        function mat = processFile(obj, ref, ids)
            % Preallocate matrix
            mat = zeros( size(ids) );
            
            % Iterate over IDs (i)
            for i=1:size(ref,2)
                mat( ids == i ) = ref(1,i);
            end
        end
        
        function obj = processFolder(obj, folderName)
            pids = csvread( fullfile('.', 'data', folderName, 'ids', 'convDiPos.csv') );
            nids = csvread( fullfile('.', 'data', folderName, 'ids', 'convDiNeg.csv') );

            % Process Dinucs
            refDiTable = csvread( fullfile('.', 'ref_tables', 'dinuc_values') );
            disp('DINUCS');
            for i=1:38
                disp(i);
                ref = refDiTable(i,:);
                
                mat = obj.processFile(ref, pids);
                fname = sprintf('pos-di-%02d.dat', i);
                csvwrite( fullfile('.', 'data', folderName, fname), mat );
                
                mat = obj.processFile(ref, nids);
                fname = sprintf('neg-di-%02d.dat', i);
                csvwrite( fullfile('.', 'data', folderName, fname), mat );
            end
            
            % Process Trinucs
            refTriTable = csvread( fullfile('.', 'ref_tables', 'trinuc_values') );
            disp('TRINUCS');
            for i=1:12
                disp(i);
                ref = refTriTable(i,:);
                
                mat = obj.processFile(ref, pids);
                fname = sprintf('pos-tri-%02d.dat', i);
                csvwrite( fullfile('.', 'data', folderName, fname), mat );
                
                mat = obj.processFile(ref, nids);
                fname = sprintf('neg-tri-%02d.dat', i);
                csvwrite( fullfile('.', 'data', folderName, fname), mat );
            end
            
        end
        
        function processAllDataSets(obj)    
            datasets = obj.getDatasetsNames();
            
            for i=1:size(datasets,2)
                folderName = datasets{1,i};
                disp( folderName );
                obj.processFolder(folderName);
            end
        end

        
    end
    
end


 function createNewDb()
    posfasta=fullfile('..','');
    negfasta='';
    db=DBCreate(posfasta,negfasta);
    db.get_sequences();
 end