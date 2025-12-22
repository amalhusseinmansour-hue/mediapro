<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\N8nWorkflow;

class N8nWorkflowsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $workflows = [
            // Instagram Post Workflow
            [
                'workflow_id' => 's0nPCN4TRazlUdMG',
                'name' => 'Instagram Post',
                'description' => 'Upload video to Instagram using N8N and Upload Post',
                'platform' => 'instagram',
                'type' => 'video',
                'credential_id' => 'dLFyi5YuHVC19jyf',
                'upload_post_user' => 'uploadn8n',
                'input_schema' => [
                    'fileID' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Google Drive file ID'
                    ],
                    'text' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Post caption/title'
                    ]
                ],
                'workflow_json' => [
                    'name' => 'Instagram Post',
                    'nodes' => [
                        [
                            'parameters' => [
                                'workflowInputs' => [
                                    'values' => [
                                        ['name' => 'fileID'],
                                        ['name' => 'text']
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.executeWorkflowTrigger',
                            'typeVersion' => 1.1,
                            'position' => [0, 0],
                            'id' => 'dc3975c0-0a1d-46fc-8dbe-e507bc2fca4d',
                            'name' => 'When Executed by Another Workflow'
                        ],
                        [
                            'parameters' => [
                                'operation' => 'uploadVideo',
                                'user' => 'uploadn8n',
                                'platform' => ['instagram'],
                                'title' => '={{ $("When Executed by Another Workflow").item.json.text }}',
                                'video' => '=https://drive.google.com/uc?export=download&id={{ $json.fileID }}'
                            ],
                            'type' => 'n8n-nodes-upload-post.uploadPost',
                            'typeVersion' => 1,
                            'position' => [256, 0],
                            'id' => '7857e68b-0ac4-4767-95ee-3c68faa31e4e',
                            'name' => 'Upload a video',
                            'credentials' => [
                                'uploadPostApi' => [
                                    'id' => 'dLFyi5YuHVC19jyf',
                                    'name' => 'Upload Post account'
                                ]
                            ]
                        ]
                    ],
                    'connections' => [
                        'When Executed by Another Workflow' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Upload a video',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ]
                    ],
                    'active' => false,
                    'settings' => ['executionOrder' => 'v1'],
                    'id' => 's0nPCN4TRazlUdMG'
                ],
                'is_active' => true
            ],

            // TikTok Post Workflow
            [
                'workflow_id' => 'qTtpNHAxoRJdleEH',
                'name' => 'TikTok Post Tool',
                'description' => 'Upload video to TikTok using N8N and Upload Post',
                'platform' => 'tiktok',
                'type' => 'video',
                'credential_id' => 'dLFyi5YuHVC19jyf',
                'upload_post_user' => 'uploadn8n',
                'input_schema' => [
                    'fileID' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Google Drive file ID'
                    ],
                    'text' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Post title and description'
                    ]
                ],
                'workflow_json' => [
                    'name' => 'TikTok Post Tool',
                    'nodes' => [
                        [
                            'parameters' => [
                                'workflowInputs' => [
                                    'values' => [
                                        ['name' => 'fileID'],
                                        ['name' => 'text']
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.executeWorkflowTrigger',
                            'typeVersion' => 1.1,
                            'position' => [0, 0],
                            'id' => 'b7ae2211-cb07-4b36-ae72-4d15990e29d4',
                            'name' => 'When Executed by Another Workflow'
                        ],
                        [
                            'parameters' => [
                                'operation' => 'uploadVideo',
                                'user' => 'uploadn8n',
                                'platform' => ['tiktok'],
                                'title' => '={{ $("When Executed by Another Workflow").item.json.text }}',
                                'description' => '={{ $("When Executed by Another Workflow").item.json.text }}',
                                'video' => '=https://drive.google.com/uc?export=download&id={{ $json.fileID }}'
                            ],
                            'type' => 'n8n-nodes-upload-post.uploadPost',
                            'typeVersion' => 1,
                            'position' => [208, 0],
                            'id' => '86767b36-8a93-45ba-ad8b-34f792c6e35a',
                            'name' => 'Upload a video',
                            'credentials' => [
                                'uploadPostApi' => [
                                    'id' => 'dLFyi5YuHVC19jyf',
                                    'name' => 'Upload Post account'
                                ]
                            ]
                        ]
                    ],
                    'connections' => [
                        'When Executed by Another Workflow' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Upload a video',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ]
                    ],
                    'active' => false,
                    'settings' => ['executionOrder' => 'v1'],
                    'id' => 'qTtpNHAxoRJdleEH'
                ],
                'is_active' => true
            ],

            // YouTube Post Workflow
            [
                'workflow_id' => '9VoXf7KVsMzlBm4T',
                'name' => 'Youtube Post',
                'description' => 'Upload video to YouTube using N8N and Upload Post',
                'platform' => 'youtube',
                'type' => 'video',
                'credential_id' => 'dLFyi5YuHVC19jyf',
                'upload_post_user' => 'uploadn8n',
                'input_schema' => [
                    'fileID' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Google Drive file ID'
                    ],
                    'text' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Video title and description'
                    ]
                ],
                'workflow_json' => [
                    'name' => 'Youtube Post',
                    'nodes' => [
                        [
                            'parameters' => [
                                'workflowInputs' => [
                                    'values' => [
                                        ['name' => 'fileID'],
                                        ['name' => 'text']
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.executeWorkflowTrigger',
                            'typeVersion' => 1.1,
                            'position' => [336, -176],
                            'id' => '5a21b213-b9df-4798-b507-2f6e1a27c89a',
                            'name' => 'When Executed by Another Workflow'
                        ],
                        [
                            'parameters' => [
                                'operation' => 'uploadVideo',
                                'user' => 'uploadn8n',
                                'platform' => ['youtube'],
                                'title' => '={{ $("When Executed by Another Workflow").item.json.text }}',
                                'description' => '={{ $("When Executed by Another Workflow").item.json.text }}',
                                'video' => '=https://drive.google.com/uc?export=download&id={{ $json.fileID }}'
                            ],
                            'type' => 'n8n-nodes-upload-post.uploadPost',
                            'typeVersion' => 1,
                            'position' => [544, -176],
                            'id' => '87f295df-f046-4bd0-849e-37085ffb8a6d',
                            'name' => 'Upload a video',
                            'credentials' => [
                                'uploadPostApi' => [
                                    'id' => 'dLFyi5YuHVC19jyf',
                                    'name' => 'Upload Post account'
                                ]
                            ]
                        ]
                    ],
                    'connections' => [
                        'When Executed by Another Workflow' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Upload a video',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ]
                    ],
                    'active' => false,
                    'settings' => ['executionOrder' => 'v1'],
                    'id' => '9VoXf7KVsMzlBm4T'
                ],
                'is_active' => true
            ],

            // Edit Image Workflow
            [
                'workflow_id' => 'QDmg9rBsQuXE8vx9',
                'name' => 'Edit Image Tool',
                'description' => 'AI-powered image editing using Kie.ai nano banana model',
                'platform' => 'ai-tools',
                'type' => 'image',
                'credential_id' => 'hG1UKwcbFnmtNIPu',
                'upload_post_user' => 'n8n',
                'input_schema' => [
                    'image' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Image file name'
                    ],
                    'request' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Edit request/prompt (what to change in the image)'
                    ],
                    'chatID' => [
                        'type' => 'string',
                        'required' => false,
                        'description' => 'Telegram chat ID (optional)'
                    ],
                    'pictureID' => [
                        'type' => 'string',
                        'required' => true,
                        'description' => 'Google Drive picture ID'
                    ]
                ],
                'workflow_json' => [
                    'name' => 'Edit Image Tool',
                    'nodes' => [
                        [
                            'parameters' => [
                                'workflowInputs' => [
                                    'values' => [
                                        ['name' => 'image'],
                                        ['name' => 'request'],
                                        ['name' => 'chatID'],
                                        ['name' => 'pictureID']
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.executeWorkflowTrigger',
                            'typeVersion' => 1.1,
                            'position' => [-1360, 192],
                            'id' => '07e7dc46-1f25-47fc-b265-883837ecc329',
                            'name' => 'When Executed by Another Workflow'
                        ],
                        [
                            'parameters' => [
                                'operation' => 'download',
                                'fileId' => [
                                    '__rl' => true,
                                    'value' => '={{ $json.pictureID }}',
                                    'mode' => 'id'
                                ]
                            ],
                            'type' => 'n8n-nodes-base.googleDrive',
                            'typeVersion' => 3,
                            'position' => [-1104, 192],
                            'id' => '302b0fc0-b300-476b-a99b-3b8fd92a26c4',
                            'name' => 'Download'
                        ],
                        [
                            'parameters' => [
                                'operation' => 'share',
                                'fileId' => [
                                    '__rl' => true,
                                    'value' => '={{ $json.pictureID }}',
                                    'mode' => 'id'
                                ],
                                'permissionsUi' => [
                                    'permissionsValues' => [
                                        'role' => 'reader',
                                        'type' => 'anyone'
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.googleDrive',
                            'typeVersion' => 3,
                            'position' => [-896, 192],
                            'id' => 'd9ef5430-4b31-4c15-93e0-f542db9040a7',
                            'name' => 'Share file'
                        ],
                        [
                            'parameters' => [
                                'assignments' => [
                                    'assignments' => [
                                        [
                                            'id' => 'dfe2a471-a613-4fc3-95f3-48af731e37b0',
                                            'name' => 'url',
                                            'value' => '={ "image_url":"https://drive.google.com/uc?export=view&id={{ $(\'When Executed by Another Workflow\').item.json.pictureID }}" }',
                                            'type' => 'string'
                                        ]
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.set',
                            'typeVersion' => 3.4,
                            'position' => [-688, 192],
                            'id' => '9902fd08-ae2d-4243-88f8-9f5534452690',
                            'name' => 'url'
                        ],
                        [
                            'parameters' => [
                                'method' => 'POST',
                                'url' => 'https://api.kie.ai/api/v1/jobs/createTask',
                                'authentication' => 'genericCredentialType',
                                'genericAuthType' => 'httpHeaderAuth',
                                'sendBody' => true,
                                'specifyBody' => 'json',
                                'jsonBody' => '={"model": "google/nano-banana-edit","input": {"prompt": "{{ $(\'When Executed by Another Workflow\').item.json.request.replace(/"/g, \'\') }}","image_urls": ["{{ JSON.parse($json.url).image_url }}"],"output_format": "png","image_size": "9:16"}}'
                            ],
                            'type' => 'n8n-nodes-base.httpRequest',
                            'typeVersion' => 4.2,
                            'position' => [-496, 192],
                            'id' => '074f081d-0bd2-4ab7-a51d-2d8fdb857e53',
                            'name' => 'nano banana (edit)'
                        ],
                        [
                            'parameters' => [
                                'amount' => 1
                            ],
                            'type' => 'n8n-nodes-base.wait',
                            'typeVersion' => 1.1,
                            'position' => [-272, 192],
                            'id' => 'f4073ba0-9a1d-44e6-be81-09857a21b4f9',
                            'name' => 'Wait ~ 25 sec'
                        ],
                        [
                            'parameters' => [
                                'url' => 'https://api.kie.ai/api/v1/jobs/recordInfo',
                                'authentication' => 'genericCredentialType',
                                'genericAuthType' => 'httpHeaderAuth',
                                'sendQuery' => true,
                                'queryParameters' => [
                                    'parameters' => [
                                        [
                                            'name' => 'taskId',
                                            'value' => '={{ $json.data.taskId }}'
                                        ]
                                    ]
                                ]
                            ],
                            'type' => 'n8n-nodes-base.httpRequest',
                            'typeVersion' => 4.2,
                            'position' => [-112, 192],
                            'id' => 'a1742cdb-ff73-4532-b212-9b8b507bc608',
                            'name' => 'Get_Image'
                        ]
                    ],
                    'connections' => [
                        'When Executed by Another Workflow' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Download',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ],
                        'Download' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Share file',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ],
                        'Share file' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'url',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ],
                        'url' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'nano banana (edit)',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ],
                        'nano banana (edit)' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Wait ~ 25 sec',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ],
                        'Wait ~ 25 sec' => [
                            'main' => [
                                [
                                    [
                                        'node' => 'Get_Image',
                                        'type' => 'main',
                                        'index' => 0
                                    ]
                                ]
                            ]
                        ]
                    ],
                    'active' => false,
                    'settings' => ['executionOrder' => 'v1'],
                    'id' => 'QDmg9rBsQuXE8vx9'
                ],
                'is_active' => true
            ]
        ];

        foreach ($workflows as $workflow) {
            N8nWorkflow::updateOrCreate(
                ['workflow_id' => $workflow['workflow_id']],
                $workflow
            );
        }

        $this->command->info('✅ N8N Workflows seeded successfully!');
        $this->command->info('Total workflows created: ' . count($workflows));
    }
}
