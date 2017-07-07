classdef MimSubjectList < MimModel
    properties (Access = private)
        SubjectList
        Mim
    end
        
    methods
        function obj = MimSubjectList(modelId, parameters, modelMap, autoUpdate)
            obj = obj@MimModel(modelId, parameters, modelMap, autoUpdate);
            obj.Mim = modelMap.getMim();
        end
        
        function value = run(obj)
            if isempty(obj.SubjectList)
                obj.updateSubjectList();
            end
            value = obj.SubjectList;
        end
        
        function updateSubjectList(obj)
            database = obj.Mim.GetImageDatabase();
            [projectNames, projectIds] = database.GetListOfProjects();
            strhash = int2str(obj.Hash);
            subjectList = {};
            for projectIndex = 1 : numel(projectNames)
                projectName = projectNames{projectIndex};
                projectId = projectIds{projectIndex};
                [names, ids, short_visible_names, num_series, num_patients_combined, patient_id_map] = database.GetListOfPatientNamesAndSeriesCount(projectId, true);
                for nameIndex = 1 : numel(names)
                    subjectId = ids{nameIndex};
                    name = names{nameIndex};
                    parameters = {};
                    parameters.subjectId = subjectId;
                    parameters.projectName = projectName;
                    parameters.projectId = projectId;
                    parameters.subjectName = name;
                    
                    modelId = obj.buildModelId('MimWSSubject', parameters);
                    subjectList{end + 1} = MimSubjectList.SubjectListEntry(modelId, name, subjectId, projectName, [], []);
                    
                end
            end
            obj.SubjectList = subjectList;
        end
    end
    
    methods (Static)
        function key = getKeyFromParameters(parameters)
            key = 'MimSubjectList';
        end
    end
    
    methods (Static, Access = private)
        function subjectListEntry = SubjectListEntry(modelId, label, id, project, uri, insert_date)
            subjectListEntry = struct();
            subjectListEntry.modelUid = modelId;
            subjectListEntry.label = label;
            subjectListEntry.ID = id;
            subjectListEntry.project = project;
            subjectListEntry.URI = uri;
            subjectListEntry.insert_date = insert_date;
        end        
    end
end