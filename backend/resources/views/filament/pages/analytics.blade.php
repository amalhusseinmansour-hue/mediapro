<x-filament-panels::page>
    <div class="space-y-6">
        {{-- Filters Section --}}
        <x-filament::section>
            <x-slot name="heading">
                <div class="flex items-center justify-between">
                    <span>Filter Analytics</span>
                    <x-filament::button wire:click="exportCsv" color="success" icon="heroicon-o-arrow-down-tray">
                        Export CSV
                    </x-filament::button>
                </div>
            </x-slot>

            <form wire:submit.prevent="$refresh">
                {{ $this->form }}
            </form>
        </x-filament::section>

        {{-- Overview Stats --}}
        @php
            $stats = $this->getOverviewStats();
        @endphp

        <x-filament::section>
            <x-slot name="heading">
                Overview Statistics
            </x-slot>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                {{-- Total Users --}}
                <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Total Users</p>
                            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ number_format($stats['total_users']) }}</p>
                            <p class="text-xs text-green-600 dark:text-green-400 mt-1">
                                +{{ $stats['new_users'] }} this period
                            </p>
                        </div>
                        <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
                            <x-heroicon-o-users class="w-6 h-6 text-blue-600 dark:text-blue-400"/>
                        </div>
                    </div>
                </div>

                {{-- Total Posts --}}
                <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Total Posts</p>
                            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ number_format($stats['total_posts']) }}</p>
                            <p class="text-xs text-green-600 dark:text-green-400 mt-1">
                                +{{ $stats['posts_in_period'] }} this period
                            </p>
                        </div>
                        <div class="w-12 h-12 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                            <x-heroicon-o-document-text class="w-6 h-6 text-purple-600 dark:text-purple-400"/>
                        </div>
                    </div>
                </div>

                {{-- Connected Accounts --}}
                <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Connected Accounts</p>
                            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ number_format($stats['total_accounts']) }}</p>
                            <p class="text-xs text-green-600 dark:text-green-400 mt-1">
                                {{ $stats['active_accounts'] }} active
                            </p>
                        </div>
                        <div class="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
                            <x-heroicon-o-link class="w-6 h-6 text-green-600 dark:text-green-400"/>
                        </div>
                    </div>
                </div>

                {{-- Active Subscriptions --}}
                <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Subscriptions</p>
                            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ number_format($stats['active_subscriptions']) }}</p>
                            <p class="text-xs text-gray-600 dark:text-gray-400 mt-1">
                                of {{ $stats['total_subscriptions'] }} total
                            </p>
                        </div>
                        <div class="w-12 h-12 bg-yellow-100 dark:bg-yellow-900 rounded-lg flex items-center justify-center">
                            <x-heroicon-o-currency-dollar class="w-6 h-6 text-yellow-600 dark:text-yellow-400"/>
                        </div>
                    </div>
                </div>
            </div>

            {{-- Post Status Stats --}}
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
                <div class="bg-green-50 dark:bg-green-900/20 rounded-lg p-4">
                    <p class="text-sm text-gray-600 dark:text-gray-400">Published Posts</p>
                    <p class="text-xl font-bold text-green-600 dark:text-green-400">{{ number_format($stats['published_posts']) }}</p>
                </div>

                <div class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4">
                    <p class="text-sm text-gray-600 dark:text-gray-400">Scheduled Posts</p>
                    <p class="text-xl font-bold text-blue-600 dark:text-blue-400">{{ number_format($stats['scheduled_posts']) }}</p>
                </div>

                <div class="bg-red-50 dark:bg-red-900/20 rounded-lg p-4">
                    <p class="text-sm text-gray-600 dark:text-gray-400">Failed Posts</p>
                    <p class="text-xl font-bold text-red-600 dark:text-red-400">{{ number_format($stats['failed_posts']) }}</p>
                </div>
            </div>
        </x-filament::section>

        {{-- Platform Performance --}}
        @php
            $platformPerformance = $this->getPlatformPerformance();
        @endphp

        @if(count($platformPerformance) > 0)
            <x-filament::section>
                <x-slot name="heading">
                    Platform Performance
                </x-slot>

                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <th class="text-left py-3 px-4">Platform</th>
                                <th class="text-center py-3 px-4">Total</th>
                                <th class="text-center py-3 px-4">Published</th>
                                <th class="text-center py-3 px-4">Failed</th>
                                <th class="text-center py-3 px-4">Pending</th>
                                <th class="text-center py-3 px-4">Success Rate</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($platformPerformance as $platform)
                                <tr class="border-b border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800/50">
                                    <td class="py-3 px-4 font-medium">{{ $platform['platform'] }}</td>
                                    <td class="text-center py-3 px-4">{{ $platform['total'] }}</td>
                                    <td class="text-center py-3 px-4 text-green-600 dark:text-green-400">{{ $platform['published'] }}</td>
                                    <td class="text-center py-3 px-4 text-red-600 dark:text-red-400">{{ $platform['failed'] }}</td>
                                    <td class="text-center py-3 px-4 text-blue-600 dark:text-blue-400">{{ $platform['pending'] }}</td>
                                    <td class="text-center py-3 px-4">
                                        <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium
                                            @if($platform['success_rate'] >= 80) bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400
                                            @elseif($platform['success_rate'] >= 60) bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400
                                            @else bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400
                                            @endif">
                                            {{ $platform['success_rate'] }}%
                                        </span>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </x-filament::section>
        @endif

        {{-- Top Users --}}
        @php
            $topUsers = $this->getTopUsers();
        @endphp

        @if(count($topUsers) > 0)
            <x-filament::section>
                <x-slot name="heading">
                    Top Content Creators
                </x-slot>

                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                <th class="text-left py-3 px-4">User</th>
                                <th class="text-left py-3 px-4">Email</th>
                                <th class="text-center py-3 px-4">Total Posts</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($topUsers as $user)
                                <tr class="border-b border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800/50">
                                    <td class="py-3 px-4 font-medium">{{ $user['name'] }}</td>
                                    <td class="py-3 px-4 text-gray-600 dark:text-gray-400">{{ $user['email'] }}</td>
                                    <td class="text-center py-3 px-4">
                                        <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400">
                                            {{ $user['posts_count'] }} posts
                                        </span>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </x-filament::section>
        @endif

        {{-- Recent Posts --}}
        @php
            $recentPosts = $this->getRecentPosts();
        @endphp

        @if(count($recentPosts) > 0)
            <x-filament::section>
                <x-slot name="heading">
                    Recent Posts
                </x-slot>

                <div class="space-y-3">
                    @foreach($recentPosts as $post)
                        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                            <div class="flex items-start justify-between">
                                <div class="flex-1">
                                    <div class="flex items-center space-x-2 mb-2">
                                        <span class="text-sm font-medium text-gray-900 dark:text-white">{{ $post['user'] }}</span>
                                        <span class="text-xs text-gray-500 dark:text-gray-400">{{ $post['created_at'] }}</span>
                                    </div>
                                    <p class="text-sm text-gray-600 dark:text-gray-300 mb-2">{{ $post['content'] }}</p>
                                    <div class="flex items-center space-x-2">
                                        <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium
                                            @if($post['status'] === 'published') bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400
                                            @elseif($post['status'] === 'scheduled') bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400
                                            @elseif($post['status'] === 'failed') bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400
                                            @else bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400
                                            @endif">
                                            {{ ucfirst($post['status']) }}
                                        </span>
                                        @if($post['platforms'])
                                            @foreach($post['platforms'] as $platform)
                                                <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400">
                                                    {{ ucfirst($platform) }}
                                                </span>
                                            @endforeach
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </x-filament::section>
        @endif
    </div>
</x-filament-panels::page>
